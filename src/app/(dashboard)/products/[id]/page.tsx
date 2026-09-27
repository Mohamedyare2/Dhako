import { createClient } from "@/lib/supabase/server"
import { redirect } from "next/navigation"
import EditProductForm from "./edit-form"

export default async function EditProductPage({ params }: { params: { id: string } }) {
  const supabase = createClient()
  
  // Verify admin
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) redirect("/login")
    
  const { data: profile } = await supabase.from("profiles").select("role").eq("id", user.id).single()
  if (profile?.role !== 'admin') {
    return <div className="p-6 text-red-500">Kaliya Admin ayaa bedeli kara alaabta. (Admins only)</div>
  }

  const { data: product } = await supabase.from("products").select("*").eq("id", params.id).single()
  
  if (!product) {
    return <div className="p-6">Alaabta lama helin (Product not found).</div>
  }

  return (
    <div className="max-w-2xl mx-auto space-y-6">
      <div>
        <h2 className="text-2xl font-bold tracking-tight">Bedel Alaabta (Edit Product)</h2>
      </div>
      <EditProductForm product={product} />
    </div>
  )
}
