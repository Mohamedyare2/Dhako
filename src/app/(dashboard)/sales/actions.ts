"use server"

import { createClient } from "@/lib/supabase/server"
import { createClient as createSupabaseClient } from "@supabase/supabase-js"
import { revalidatePath } from "next/cache"

// Create a service-role admin client that bypasses RLS for admin operations
function createAdminClient() {
  const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY
  if (!serviceRoleKey) {
    throw new Error("SUPABASE_SERVICE_ROLE_KEY environment variable is missing. Please add it to your Vercel project settings.")
  }
  return createSupabaseClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    serviceRoleKey,
    { auth: { autoRefreshToken: false, persistSession: false } }
  )
}

export async function undoSale(saleId: string) {
  // Use the regular client to verify authentication/authorization
  const supabase = createClient()

  // 1. Verify user is authenticated
  const { data: { user }, error: authError } = await supabase.auth.getUser()
  if (authError || !user) throw new Error("Fadlan login samee si aad ugu soo gasho")

  // 2. Verify admin role
  const { data: profile } = await supabase
    .from("profiles")
    .select("role, full_name")
    .eq("id", user.id)
    .single()

  if (profile?.role !== "admin") {
    throw new Error("Kaliya admin ayaa awood u leh inuu Undo sameeyo. Xiriir admin.")
  }

  // 3. Fetch the sale and its items (regular client is fine for reading)
  const { data: sale, error: saleError } = await supabase
    .from("sales")
    .select("*, sale_items(*)")
    .eq("id", saleId)
    .single()

  if (saleError || !sale) {
    throw new Error("Iibkani lama helin. Laga yaabaa in hore loo tirtiray ama lambarka khalad yahay.")
  }

  // 4. Use admin client for all write operations (bypasses RLS safely)
  const supabaseAdmin = createAdminClient()

  // 5. Restore product stock quantities and log movements
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

      // Update product stock via admin client
      const { error: stockError } = await supabaseAdmin
        .from("products")
        .update({ quantity_on_hand: newQuantity })
        .eq("id", item.product_id)

      if (stockError) {
        throw new Error(`Kaydka la cusboonaysiin kari waayay (${item.product_name_raw || "alaab"}): ${stockError.message}`)
      }

      // Log the stock restoration
      await supabaseAdmin.from("stock_movements").insert({
        product_id: item.product_id,
        movement_type: "adjustment_increase",
        quantity_change: item.quantity,
        quantity_before: product.quantity_on_hand,
        quantity_after: newQuantity,
        reference_id: saleId,
        notes: `Undo Iib - Alaabtii la celiyay kaydka. Iib ID: ${saleId.slice(0, 8).toUpperCase()}`,
        performed_by: user.id,
      })
    }
  }

  // 6. Find and delete related credit_accounts if this was a credit/partial sale
  if (sale.payment_status === "credit" || sale.payment_status === "partial") {
    let creditDeleted = false

    // Primary method: match by sale_id FK (reliable, set when sale was created)
    try {
      const { data: creditsBySaleId } = await supabaseAdmin
        .from("credit_accounts")
        .select("id")
        .eq("sale_id", saleId)

      if (creditsBySaleId && creditsBySaleId.length > 0) {
        for (const c of creditsBySaleId) {
          await supabaseAdmin.from("credit_accounts").delete().eq("id", c.id)
        }
        creditDeleted = true
      }
    } catch {
      // sale_id column might not exist on older records — fall through to heuristic
    }

    // Fallback: heuristic match by customer + amount + time window
    if (!creditDeleted) {
      const saleCreatedAt = new Date(sale.created_at).getTime()

      let creditQuery = supabaseAdmin
        .from("credit_accounts")
        .select("id, created_at")
        .eq("amount_owed", sale.total_amount)

      if (sale.customer_id) {
        creditQuery = creditQuery.eq("customer_id", sale.customer_id)
      } else if (sale.customer_name_raw) {
        creditQuery = creditQuery.eq("customer_name_raw", sale.customer_name_raw)
      }

      const { data: matchedCredits } = await creditQuery

      if (matchedCredits && matchedCredits.length > 0) {
        for (const credit of matchedCredits) {
          const creditTime = new Date(credit.created_at).getTime()
          // Within 5 minutes
          if (Math.abs(creditTime - saleCreatedAt) < 300000) {
            await supabaseAdmin.from("credit_accounts").delete().eq("id", credit.id)
          }
        }
      }
    }
  }

  // 7. Write audit log entry
  await supabaseAdmin.from("audit_logs").insert({
    user_id: user.id,
    action: "UNDO_SALE",
    entity_type: "sales",
    entity_id: saleId,
    old_value: {
      total_amount: sale.total_amount,
      amount_paid: sale.amount_paid,
      balance_due: sale.balance_due,
      payment_status: sale.payment_status,
      customer_id: sale.customer_id,
      customer_name_raw: sale.customer_name_raw,
      sale_date: sale.sale_date,
      items_count: sale.sale_items?.length ?? 0,
    },
    new_value: {
      action: "deleted_via_undo",
      performed_by_id: user.id,
      performed_by_name: profile?.full_name ?? user.email,
      timestamp: new Date().toISOString(),
    },
  })

  // 8. Delete the sale — sale_items cascade via FK
  const { error: deleteError } = await supabaseAdmin
    .from("sales")
    .delete()
    .eq("id", saleId)

  if (deleteError) {
    throw new Error(`Iibka tirtirista ka dhacday cillad: ${deleteError.message}`)
  }

  // 9. Revalidate all pages that show sale/credit/stock data
  revalidatePath("/sales")
  revalidatePath("/credit")
  revalidatePath("/products")
  revalidatePath("/dashboard")
  revalidatePath("/inventory")
  revalidatePath("/reports")
}
