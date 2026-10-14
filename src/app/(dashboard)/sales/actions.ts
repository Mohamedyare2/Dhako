"use server"

import { createClient } from "@/lib/supabase/server"
import { revalidatePath } from "next/cache"

export async function undoSale(saleId: string) {
  const supabase = createClient()

  // 1. Verify user is authenticated and is an admin
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) throw new Error("Fadlan login samee")

  const { data: profile } = await supabase
    .from("profiles")
    .select("role")
    .eq("id", user.id)
    .single()

  if (profile?.role !== "admin") {
    throw new Error("Kaliya admin ayaa awood u leh inuu Undo sameeyo")
  }

  // 2. Fetch the sale and its items
  const { data: sale, error: saleError } = await supabase
    .from("sales")
    .select("*, sale_items(*)")
    .eq("id", saleId)
    .single()

  if (saleError || !sale) {
    throw new Error("Iibkani lama helin. Laga yaabaa in hore loo tirtiray.")
  }

  // 3. Restore product stock quantities and log movements
  if (sale.sale_items && sale.sale_items.length > 0) {
    for (const item of sale.sale_items) {
      if (!item.product_id) continue

      const { data: product } = await supabase
        .from("products")
        .select("quantity_on_hand, name")
        .eq("id", item.product_id)
        .single()

      if (!product) continue

      const newQuantity = product.quantity_on_hand + item.quantity

      // Update product stock
      const { error: stockError } = await supabase
        .from("products")
        .update({ quantity_on_hand: newQuantity })
        .eq("id", item.product_id)

      if (stockError) {
        throw new Error(`Kaydka la cusboonaysiin kari waayay: ${product.name}. ${stockError.message}`)
      }

      // Log the stock restoration as an adjustment
      await supabase.from("stock_movements").insert({
        product_id: item.product_id,
        movement_type: "adjustment_increase",
        quantity_change: item.quantity,
        quantity_before: product.quantity_on_hand,
        quantity_after: newQuantity,
        reference_id: saleId,
        notes: `Undo Iib - Alaabtii la celiyay kaydka. Iib ID: ${saleId.slice(0, 8)}`,
        performed_by: user.id,
      })
    }
  }

  // 4. Find and delete the related credit_accounts entry
  // Strategy: Match by sale_id (if linked), then fallback to customer + amount + time window
  if (sale.payment_status === "credit" || sale.payment_status === "partial") {
    // First try: match by sale_id field (if migration 009 was applied)
    let creditDeleted = false
    
    try {
      const { data: creditBySaleId } = await supabase
        .from("credit_accounts")
        .select("id")
        .eq("sale_id", saleId)

      if (creditBySaleId && creditBySaleId.length > 0) {
        for (const c of creditBySaleId) {
          await supabase.from("credit_accounts").delete().eq("id", c.id)
        }
        creditDeleted = true
      }
    } catch {
      // sale_id column may not exist — fallback to heuristic
    }

    // Second try: heuristic match if sale_id linking didn't work
    if (!creditDeleted) {
      const saleCreatedAt = new Date(sale.created_at).getTime()
      
      // Build query based on customer type
      let creditQuery = supabase
        .from("credit_accounts")
        .select("id, created_at, amount_owed")
        .eq("amount_owed", sale.total_amount)

      // Add customer filter
      if (sale.customer_id) {
        creditQuery = creditQuery.eq("customer_id", sale.customer_id)
      } else if (sale.customer_name_raw) {
        creditQuery = creditQuery.eq("customer_name_raw", sale.customer_name_raw)
      }

      const { data: matchedCredits } = await creditQuery

      if (matchedCredits && matchedCredits.length > 0) {
        for (const credit of matchedCredits) {
          const creditTime = new Date(credit.created_at).getTime()
          // Match within 5 minutes
          if (Math.abs(creditTime - saleCreatedAt) < 300000) {
            await supabase.from("credit_accounts").delete().eq("id", credit.id)
          }
        }
      }
    }
  }

  // 5. Log the undo action in audit_logs for the audit trail
  await supabase.from("audit_logs").insert({
    user_id: user.id,
    action: "UNDO_SALE",
    entity_type: "sales",
    entity_id: saleId,
    old_value: {
      total_amount: sale.total_amount,
      amount_paid: sale.amount_paid,
      payment_status: sale.payment_status,
      customer_id: sale.customer_id,
      customer_name_raw: sale.customer_name_raw,
      items_count: sale.sale_items?.length ?? 0,
    },
    new_value: {
      action: "deleted",
      performed_by: user.id,
      timestamp: new Date().toISOString(),
    },
  })

  // 6. Delete the sale (sale_items cascade via FK)
  const { error: deleteError } = await supabase
    .from("sales")
    .delete()
    .eq("id", saleId)

  if (deleteError) {
    throw new Error(`Iibka tirtirista ka dhacday cillad: ${deleteError.message}`)
  }

  // 7. Revalidate all affected pages
  revalidatePath("/sales")
  revalidatePath("/credit")
  revalidatePath("/products")
  revalidatePath("/dashboard")
  revalidatePath("/inventory")
}
