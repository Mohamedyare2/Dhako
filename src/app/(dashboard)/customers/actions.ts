"use server"

import { createClient } from "@/lib/supabase/server"
import { revalidatePath } from "next/cache"

export async function createCustomer(formData: FormData) {
  const supabase = createClient()
  const name = formData.get("name") as string
  const phone = formData.get("phone") as string
  const notes = formData.get("notes") as string

  if (!name) throw new Error("Fadlan geli magaca macmiilka")

  const { error } = await supabase.from("customers").insert({
    name,
    phone,
    notes,
  })

  if (error) throw new Error(error.message)
  revalidatePath("/customers")
}

export async function updateCustomer(id: string, formData: FormData) {
  const supabase = createClient()
  const name = formData.get("name") as string
  const phone = formData.get("phone") as string
  const notes = formData.get("notes") as string

  if (!name) throw new Error("Fadlan geli magaca macmiilka")

  const { error } = await supabase.from("customers").update({
    name,
    phone,
    notes,
  }).eq("id", id)

  if (error) throw new Error(error.message)
  revalidatePath("/customers")
}

export async function deleteCustomer(id: string) {
  const supabase = createClient()
  
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) throw new Error("Fadlan login samee")

  const { data: profile } = await supabase.from("profiles").select("role").eq("id", user.id).single()
  if (profile?.role !== 'admin') {
    throw new Error("Admins kaliya ayaa tiri kara macaamiisha")
  }

  // Use service role for DELETE if RLS restricts it
  const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY
  if (!serviceRoleKey) {
    const { error } = await supabase.from("customers").delete().eq("id", id)
    if (error) throw new Error(error.message)
  } else {
    const { createClient: createSupabaseAdmin } = await import("@supabase/supabase-js")
    const supabaseAdmin = createSupabaseAdmin(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      serviceRoleKey,
      { auth: { autoRefreshToken: false, persistSession: false } }
    )
    const { error } = await supabaseAdmin.from("customers").delete().eq("id", id)
    if (error) throw new Error(error.message)
  }

  revalidatePath("/customers")
}
