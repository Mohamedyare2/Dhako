"use server"

import { createClient } from "@/lib/supabase/server"
import { revalidatePath } from "next/cache"

export async function deleteProduct(id: string) {
  const supabase = createClient()
  
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) throw new Error("Not logged in")
    
  const { data: profile } = await supabase.from("profiles").select("role").eq("id", user.id).single()
  if (profile?.role !== 'admin') {
    throw new Error("Only admins can delete products")
  }

  const { error } = await supabase.from('products').delete().eq('id', id)
  if (error) throw error
  
  revalidatePath('/products')
}

export async function createProduct(formData: FormData) {
  const supabase = createClient()
  
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) throw new Error("Fadlan login samee")

  const name = formData.get("name") as string
  const part_code = formData.get("part_code") as string
  const vehicle_model = formData.get("vehicle_model") as string
  const cost_price = parseFloat(formData.get("cost_price") as string || "0")
  const selling_price = parseFloat(formData.get("selling_price") as string || "0")
  const quantity_on_hand = parseInt(formData.get("quantity_on_hand") as string || "0")
  const min_stock_level = parseInt(formData.get("min_stock_level") as string || "5")

  const { error } = await supabase.from("products").insert([{
    name,
    part_code,
    vehicle_model,
    cost_price,
    selling_price,
    quantity_on_hand,
    min_stock_level,
    status: "active"
  }])

  if (error) {
    throw new Error(error.message)
  }

  revalidatePath("/products")
}
