"use server"

import { createClient } from "@/lib/supabase/server"
import { revalidatePath } from "next/cache"

import { createClient as createSupabaseClient } from "@supabase/supabase-js"

export async function deleteCustomerDebt(id: string) {
  const supabase = createClient()
  
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) throw new Error("Fadlan login samee")

  const { data: profile } = await supabase.from("profiles").select("role").eq("id", user.id).single()
  if (profile?.role !== 'admin') {
    throw new Error("Admins kaliya ayaa tiri kara deynta")
  }

  const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY
  if (!serviceRoleKey) {
    throw new Error("Fadlan ku dar SUPABASE_SERVICE_ROLE_KEY faylka .env.local")
  }

  const supabaseAdmin = createSupabaseClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    serviceRoleKey,
    { auth: { autoRefreshToken: false, persistSession: false } }
  )

  const { error } = await supabaseAdmin.from("credit_accounts").delete().eq("id", id)
  if (error) throw new Error(error.message)

  revalidatePath("/credit")
}

export async function createCustomerDebt(formData: FormData) {
  const supabase = createClient()
  
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) throw new Error("Fadlan login samee")

  const customer_name = formData.get("customer_name") as string
  const amount_owed = parseFloat(formData.get("amount_owed") as string || "0")
  const description = formData.get("description") as string

  // 1. Create or find customer
  let customer_id = null;
  
  const { data: existingCustomer } = await supabase
    .from("customers")
    .select("id")
    .ilike("name", customer_name)
    .single();
    
  if (existingCustomer) {
    customer_id = existingCustomer.id;
  } else {
    const { data: newCustomer } = await supabase
      .from("customers")
      .insert([{ name: customer_name }])
      .select()
      .single();
      
    if (newCustomer) {
      customer_id = newCustomer.id;
    }
  }

  // 2. Insert Debt
  const { error } = await supabase.from("credit_accounts").insert([{
    customer_id: customer_id,
    customer_name_raw: customer_name,
    amount_owed: amount_owed,
    amount_paid: 0,
    description: description,
    status: "open"
  }])

  if (error) {
    throw new Error(error.message)
  }

  revalidatePath("/credit")
}

export async function payCustomerDebt(id: string, amountToPay: number) {
  const supabase = createClient()
  
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) throw new Error("Fadlan login samee")

  // Fetch current debt
  const { data: credit, error: fetchErr } = await supabase
    .from("credit_accounts")
    .select("amount_owed, amount_paid, status")
    .eq("id", id)
    .single()

  if (fetchErr || !credit) throw new Error("Deynta lama helin")

  const newPaid = Number(credit.amount_paid) + amountToPay
  const newStatus = newPaid >= Number(credit.amount_owed) ? 'settled' : 'open'

  const { error: updateErr } = await supabase
    .from("credit_accounts")
    .update({ 
      amount_paid: newPaid,
      status: newStatus
    })
    .eq("id", id)

  if (updateErr) throw new Error(updateErr.message)

  revalidatePath("/credit")
}

export async function updateCustomerDebt(id: string, formData: FormData) {
  const supabase = createClient()
  
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) throw new Error("Fadlan login samee")

  const customer_name = formData.get("customer_name") as string
  const amount_owed = parseFloat(formData.get("amount_owed") as string || "0")
  const amount_paid = parseFloat(formData.get("amount_paid") as string || "0")
  const description = formData.get("description") as string
  
  const status = amount_paid >= amount_owed ? 'settled' : 'open'

  const { error } = await supabase.from("credit_accounts").update({
    customer_name_raw: customer_name,
    amount_owed,
    amount_paid,
    description,
    status
  }).eq("id", id)

  if (error) {
    throw new Error(error.message)
  }

  revalidatePath("/credit")
}
