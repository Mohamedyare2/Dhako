"use server"

import { createClient } from "@/lib/supabase/server"
import { revalidatePath } from "next/cache"

export async function undoSale(saleId: string) {
  const supabase = createClient()
  
  // 1. Fetch sale and items
  const { data: sale, error: saleError } = await supabase
    .from("sales")
    .select("*, sale_items(*)")
    .eq("id", saleId)
    .single()

  if (saleError || !sale) {
    throw new Error("Failed to find sale.")
  }

  // 2. Fetch current user for audit/stock movement
  const { data: { user } } = await supabase.auth.getUser()
  
  // Check if admin (optional security check)
  if (user) {
    const { data: profile } = await supabase.from("profiles").select("role").eq("id", user.id).single()
    if (profile?.role !== 'admin') {
      throw new Error("Kaliya admin ayaa awood u leh inuu Undo sameeyo")
    }
  }

  // 3. Restore product quantities
  if (sale.sale_items && sale.sale_items.length > 0) {
    for (const item of sale.sale_items) {
      if (item.product_id) {
        // Get current product quantity
        const { data: product } = await supabase
          .from("products")
          .select("quantity_on_hand")
          .eq("id", item.product_id)
          .single()
          
        if (product) {
          const newQuantity = product.quantity_on_hand + item.quantity
          
          // Update product
          await supabase
            .from("products")
            .update({ quantity_on_hand: newQuantity })
            .eq("id", item.product_id)
            
          // Log stock movement
          await supabase.from("stock_movements").insert({
            product_id: item.product_id,
            movement_type: 'adjustment_increase',
            quantity_change: item.quantity,
            quantity_before: product.quantity_on_hand,
            quantity_after: newQuantity,
            reference_id: saleId,
            notes: "Undo Sale - Restored Stock",
            performed_by: user?.id
          })
        }
      }
    }
  }

  // 4. Try to find and delete related credit_accounts if it was a credit or partial sale
  if (sale.payment_status === 'credit' || sale.payment_status === 'partial') {
    // Delete credit account where customer, amount owed match within 1 minute
    const { data: credits } = await supabase
      .from("credit_accounts")
      .select("id, created_at")
      .eq("amount_owed", sale.total_amount)
      .eq("amount_paid", sale.amount_paid)

    if (credits && credits.length > 0) {
      const saleDate = new Date(sale.created_at).getTime()
      for (const credit of credits) {
        const creditDate = new Date(credit.created_at).getTime()
        // If created within 2 minutes of each other
        if (Math.abs(creditDate - saleDate) < 120000) {
          await supabase.from("credit_accounts").delete().eq("id", credit.id)
        }
      }
    }
  }

  // 5. Delete the sale (sale_items cascade)
  const { error: deleteError } = await supabase
    .from("sales")
    .delete()
    .eq("id", saleId)

  if (deleteError) {
    throw new Error(deleteError.message)
  }

  revalidatePath("/sales")
  revalidatePath("/credit")
  revalidatePath("/products")
}
