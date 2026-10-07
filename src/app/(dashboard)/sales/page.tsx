import { createClient } from "@/lib/supabase/server"
import { Button } from "@/components/ui/button"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Badge } from "@/components/ui/badge"
import { Plus, ShoppingCart, Undo2 } from "lucide-react"
import { LiveSearch } from "@/components/ui/live-search"
import Link from "next/link"
import { undoSale } from "./actions"

export default async function SalesPage() {
  const supabase = createClient()
  
  // Verify admin role
  const { data: { user } } = await supabase.auth.getUser()
  let isAdmin = false
  if (user) {
    const { data: profile } = await supabase.from("profiles").select("role").eq("id", user.id).single()
    isAdmin = profile?.role === 'admin'
  }

  const { data: sales, error } = await supabase
    .from("sales")
    .select("*, customers(name)")
    .order("sale_date", { ascending: false })
    .limit(50)

  return (
    <div className="space-y-6 fade-in">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-2xl font-bold tracking-tight text-slate-900">Sales</h2>
          <p className="text-slate-500 text-sm mt-0.5">View and manage daily sales activity</p>
        </div>
        <Link href="/sales/new">
          <Button className="bg-slate-900 hover:bg-slate-800 text-white rounded-xl shadow-sm h-10 px-4 font-medium">
            <Plus className="mr-2 h-4 w-4" />
            New Sale
          </Button>
        </Link>
      </div>

      <div className="max-w-sm">
        <LiveSearch placeholder="Search sales..." />
      </div>

      <div className="bg-white rounded-2xl border border-slate-200/80 shadow-sm overflow-hidden">
        <Table>
          <TableHeader>
            <TableRow className="bg-slate-50/80 border-b border-slate-200">
              <TableHead className="font-semibold text-slate-700 pl-6">Date</TableHead>
              <TableHead className="font-semibold text-slate-700">Customer</TableHead>
              <TableHead className="text-right font-semibold text-slate-700">Total Amount</TableHead>
              <TableHead className="text-right font-semibold text-slate-700">Balance Due</TableHead>
              <TableHead className="font-semibold text-slate-700">Status</TableHead>
              <TableHead className="text-right font-semibold text-slate-700 pr-6">Action</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {error && (
              <TableRow>
                <TableCell colSpan={6} className="h-24 text-center text-rose-600 bg-rose-50/50">
                  ⚠️ Failed to load sales: {error.message}
                </TableCell>
              </TableRow>
            )}
            {!error && sales?.length === 0 && (
              <TableRow>
                <TableCell colSpan={6} className="py-16 text-center">
                  <ShoppingCart className="h-8 w-8 text-slate-300 mx-auto mb-2" />
                  <p className="text-sm text-slate-400">No sales recorded yet</p>
                </TableCell>
              </TableRow>
            )}
            {sales?.map((sale) => (
              <TableRow key={sale.id} className="table-row-hover border-b border-slate-100 last:border-0">
                <TableCell className="font-medium text-slate-700 pl-6 py-4">
                  {new Date(sale.sale_date).toLocaleDateString("en-GB", { day: "numeric", month: "short", year: "numeric" })}
                </TableCell>
                <TableCell className="text-slate-600">
                  {sale.customers?.name || sale.customer_name_raw || "Walk-in Customer"}
                </TableCell>
                <TableCell className="text-right font-semibold text-slate-900">
                  ${Number(sale.total_amount).toFixed(2)}
                </TableCell>
                <TableCell className="text-right text-rose-600 font-medium">
                  {sale.balance_due > 0 ? `$${Number(sale.balance_due).toFixed(2)}` : (
                    <span className="text-slate-300">—</span>
                  )}
                </TableCell>
                <TableCell>
                  <Badge
                    className={`rounded-full text-xs font-medium px-2.5 py-0.5 border-0 ${
                      sale.payment_status === 'paid'
                        ? 'bg-emerald-50 text-emerald-700'
                        : sale.payment_status === 'credit'
                        ? 'bg-amber-50 text-amber-700'
                        : 'bg-slate-100 text-slate-600'
                    }`}
                  >
                    {sale.payment_status}
                  </Badge>
                </TableCell>
                <TableCell className="text-right pr-6">
                  {isAdmin && (
                    <form>
                      <Button
                        formAction={async () => {
                          "use server"
                          await undoSale(sale.id)
                        }}
                        variant="outline"
                        size="sm"
                        className="text-rose-600 border-rose-200 hover:bg-rose-50"
                        title="Undo Sale (Celinta Alaabta)"
                      >
                        <Undo2 className="h-4 w-4 mr-2" />
                        Undo
                      </Button>
                    </form>
                  )}
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
    </div>
  )
}
