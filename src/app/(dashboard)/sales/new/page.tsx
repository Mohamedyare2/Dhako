import { createClient } from "@/lib/supabase/server"
import NewSaleForm from "./new-sale-form"

export default async function NewSalePage() {
  const supabase = createClient()
  
  const [{ data: products }, { data: customers }] = await Promise.all([
    supabase.from("products").select("id, name, selling_price, quantity_on_hand").eq("status", "active"),
    supabase.from("customers").select("id, name, phone")
  ])

  return (
    <div className="space-y-6 fade-in max-w-5xl mx-auto">
      <div>
        <h2 className="text-2xl font-bold tracking-tight text-slate-900">New Sale (Iib Cusub)</h2>
        <p className="text-slate-500 text-sm mt-0.5">Diiwaangeli iib cusub oo meheradda ah</p>
      </div>

      <NewSaleForm 
        products={products || []} 
        customers={customers || []} 
      />
    </div>
  )
}
