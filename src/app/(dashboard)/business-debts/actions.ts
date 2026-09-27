"use server"

import { createClient } from "@/lib/supabase/server"
import { revalidatePath } from "next/cache"

export async function deleteBusinessDebt(id: string) {
  const supabase = createClient()
  
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) throw new Error("Fadlan login samee")

  const { data: profile } = await supabase.from("profiles").select("role").eq("id", user.id).single()
  if (profile?.role !== 'admin') {
    throw new Error("Admins kaliya ayaa tiri kara deynta")
  }

  const { error } = await supabase.from("business_debts").delete().eq("id", id)
  if (error) throw new Error(error.message)

  revalidatePath("/business-debts")
}

export async function createBusinessDebt(formData: FormData) {
  const supabase = createClient()
  
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) throw new Error("Fadlan login samee")

  const supplier_name = formData.get("supplier_name") as string
  const amount_owed = parseFloat(formData.get("amount_owed") as string || "0")
  const description = formData.get("description") as string
  const due_date = formData.get("due_date") as string

  // 1. Create or find supplier
  let supplier_id = null;
  
  const { data: existingSupplier } = await supabase
    .from("suppliers")
    .select("id")
    .ilike("name", supplier_name)
    .single();
    
  if (existingSupplier) {
    supplier_id = existingSupplier.id;
  } else {
    const { data: newSupplier } = await supabase
      .from("suppliers")
      .insert([{ name: supplier_name }])
      .select()
      .single();
      
    if (newSupplier) {
      supplier_id = newSupplier.id;
    }
  }

  // 2. Insert Debt
  const { error } = await supabase.from("business_debts").insert([{
    supplier_id: supplier_id,
    supplier_name_raw: supplier_name,
    amount_owed: amount_owed,
    amount_paid: 0,
    description: description,
    due_date: due_date || null,
    status: "open"
  }])

  if (error) {
    throw new Error(error.message)
  }

  revalidatePath("/business-debts")
}

export async function payBusinessDebt(id: string, amountToPay: number) {
  const supabase = createClient()
  
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) throw new Error("Fadlan login samee")

  // Fetch current debt
  const { data: debt, error: fetchErr } = await supabase
    .from("business_debts")
    .select("amount_owed, amount_paid, status")
    .eq("id", id)
    .single()

  if (fetchErr || !debt) throw new Error("Deynta lama helin")

  const newPaid = Number(debt.amount_paid) + amountToPay
  const newStatus = newPaid >= Number(debt.amount_owed) ? 'settled' : 'open'

  const { error: updateErr } = await supabase
    .from("business_debts")
    .update({ 
      amount_paid: newPaid,
      status: newStatus
    })
    .eq("id", id)

  if (updateErr) throw new Error(updateErr.message)

  revalidatePath("/business-debts")
}

export async function updateBusinessDebt(id: string, formData: FormData) {
  const supabase = createClient()
  
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) throw new Error("Fadlan login samee")

  const supplier_name = formData.get("supplier_name") as string
  const amount_owed = parseFloat(formData.get("amount_owed") as string || "0")
  const amount_paid = parseFloat(formData.get("amount_paid") as string || "0")
  const description = formData.get("description") as string
  const due_date = formData.get("due_date") as string
  
  const status = amount_paid >= amount_owed ? 'settled' : 'open'

  const { error } = await supabase.from("business_debts").update({
    supplier_name_raw: supplier_name,
    amount_owed,
    amount_paid,
    description,
    due_date: due_date || null,
    status
  }).eq("id", id)

  if (error) {
    throw new Error(error.message)
  }

  revalidatePath("/business-debts")
}
