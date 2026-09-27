"use server"

import { createClient } from "@supabase/supabase-js"
import { createClient as createServerClient } from "@/lib/supabase/server"

export async function resetStaffPassword(userId: string, newPassword: string) {
  const serverClient = createServerClient()
  
  // Verify admin role
  const { data: { user } } = await serverClient.auth.getUser()
  if (!user) throw new Error("Fadlan login samee marka hore")
    
  const { data: profile } = await serverClient.from("profiles").select("role").eq("id", user.id).single()
  if (profile?.role !== 'admin') {
    throw new Error("Admins kaliya ayaa bedeli kara password-yada kale")
  }

  // Use the Service Role key to bypass RLS and use Admin Auth API
  const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY
  if (!serviceRoleKey) {
    throw new Error("Fadlan ku dar SUPABASE_SERVICE_ROLE_KEY faylkaaga .env.local marka hore si aad awoodan u hesho.")
  }

  const supabaseAdmin = createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    serviceRoleKey,
    { auth: { autoRefreshToken: false, persistSession: false } }
  )

  const { error } = await supabaseAdmin.auth.admin.updateUserById(userId, { password: newPassword })
  if (error) throw error
}
