"use server"

import { createClient } from "@/lib/supabase/server"
import { revalidatePath } from "next/cache"

export async function createCategory(formData: FormData) {
  const supabase = createClient()
  
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) throw new Error("Fadlan login samee")

  const name_so = formData.get("name_so") as string
  const name_en = formData.get("name_en") as string
  const description = formData.get("description") as string

  if (!name_so) {
    throw new Error("Magaca Af-Soomaali waa khasab")
  }

  const { error } = await supabase.from("categories").insert([{
    name_so,
    name_en,
    description
  }])

  if (error) {
    throw new Error(error.message)
  }

  revalidatePath("/categories")
}
