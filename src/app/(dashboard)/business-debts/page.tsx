import { createClient } from "@/lib/supabase/server"
import { Button } from "@/components/ui/button"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Badge } from "@/components/ui/badge"
import { Plus, Trash2, Landmark } from "lucide-react"

import Link from "next/link"
import { LiveSearch } from "@/components/ui/live-search"
import PayDebtDialog from "./pay-dialog"
import { EditBusinessDebtDialog } from "./edit-dialog"
import { deleteBusinessDebt } from "./actions"

export default async function BusinessDebtsPage({
  searchParams,
}: {
  searchParams: { q?: string }
}) {
  const supabase = createClient()
  const query = searchParams.q || ""
  
  // Verify admin role
  const { data: { user } } = await supabase.auth.getUser()
  let isAdmin = false
  if (user) {
    const { data: profile } = await supabase.from("profiles").select("role").eq("id", user.id).single()
    isAdmin = profile?.role === 'admin'
  }
  
  let dbQuery = supabase
    .from("business_debts")
    .select("*, suppliers(name)")
    .order("amount_owed", { ascending: false })

  if (query) {
    dbQuery = dbQuery.ilike("supplier_name_raw", `%${query}%`)
  }

  const { data: debts, error } = await dbQuery

  return (
    <div className="space-y-6 fade-in">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-2xl font-bold tracking-tight text-slate-900">Deynta Meheradda</h2>
          <p className="text-slate-500 text-sm mt-0.5">Accounts Payable — Deymaha shirkadaha ama dadka kale lagu leeyahay</p>
        </div>
        <Link href="/business-debts/new">
          <Button className="bg-slate-900 hover:bg-slate-800 text-white rounded-xl shadow-sm h-10 px-4 font-medium">
            <Plus className="mr-2 h-4 w-4" />
            Ku Dar Deyn
          </Button>
        </Link>
      </div>

      <div className="max-w-sm">
        <LiveSearch placeholder="Raadi Qof ama Shirkad..." />
      </div>

      <div className="bg-white rounded-2xl border border-slate-200/80 shadow-sm overflow-hidden">
        <Table>
          <TableHeader>
            <TableRow className="bg-slate-50/80 border-b border-slate-200">
              <TableHead className="font-semibold text-slate-700 pl-6">Shirkadda/Qofka (Supplier)</TableHead>
              <TableHead className="font-semibold text-slate-700">Faahfaahin (Description)</TableHead>
              <TableHead className="text-right font-semibold text-slate-700">Deynta (Total Owed)</TableHead>
              <TableHead className="text-right font-semibold text-slate-700">Haraaga (Remaining)</TableHead>
              <TableHead className="font-semibold text-slate-700">Xaalada (Status)</TableHead>
              <TableHead className="text-right font-semibold text-slate-700 pr-6">Action</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {error && (
              <TableRow>
                <TableCell colSpan={6} className="h-24 text-center text-rose-600 bg-rose-50/50">
                  Fadlan marka hore run garee SQL (008_business_debts.sql)
                </TableCell>
              </TableRow>
            )}
            {!error && (!debts || debts.length === 0) && (
              <TableRow>
                <TableCell colSpan={6} className="py-16 text-center">
                  <Landmark className="h-8 w-8 text-slate-300 mx-auto mb-2" />
                  <p className="text-sm text-slate-400">Deyn laguma laha meheradda</p>
                </TableCell>
              </TableRow>
            )}
            {debts?.map((debt) => {
              const remaining = Number(debt.amount_owed) - Number(debt.amount_paid);
              return (
                <TableRow key={debt.id} className="table-row-hover border-b border-slate-100 last:border-0">
                  <TableCell className="font-medium text-slate-900 pl-6 py-4">
                    {debt.suppliers?.name || debt.supplier_name_raw}
                  </TableCell>
                  <TableCell className="text-slate-600">{debt.description || "—"}</TableCell>
                  <TableCell className="text-right font-bold text-rose-600">
                    ${Number(debt.amount_owed).toFixed(2)}
                  </TableCell>
                  <TableCell className="text-right font-semibold text-amber-600">
                    ${remaining.toFixed(2)}
                  </TableCell>
                  <TableCell>
                    <Badge
                      className={`rounded-full text-xs font-medium px-2.5 py-0.5 border-0 ${
                        debt.status === 'open'
                          ? 'bg-rose-50 text-rose-700'
                          : 'bg-emerald-50 text-emerald-700'
                      }`}
                    >
                      {debt.status}
                    </Badge>
                  </TableCell>
                  <TableCell className="text-right pr-6">
                    <div className="flex items-center justify-end gap-2">
                      {debt.status === 'open' && (
                        <PayDebtDialog 
                          debtId={debt.id} 
                          supplierName={debt.suppliers?.name || debt.supplier_name_raw}
                          remainingAmount={remaining}
                        />
                      )}

                      <EditBusinessDebtDialog debt={debt} />

                      {isAdmin && (
                        <form>
                          <Button 
                            formAction={async () => {
                              "use server"
                              await deleteBusinessDebt(debt.id)
                            }} 
                            variant="ghost" 
                            size="icon" 
                            className="h-8 w-8 text-slate-400 hover:text-rose-600 hover:bg-rose-50 rounded-lg"
                            title="Delete Debt"
                          >
                            <Trash2 className="h-4 w-4" />
                          </Button>
                        </form>
                      )}
                    </div>
                  </TableCell>
                </TableRow>
              )
            })}
          </TableBody>
        </Table>
      </div>
    </div>
  )
}
