import { createClient } from "@/lib/supabase/server"
import { Button } from "@/components/ui/button"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Badge } from "@/components/ui/badge"
import { Plus, Trash2, CreditCard } from "lucide-react"

import Link from "next/link"
import PayCustomerDebtDialog from "./pay-dialog"
import { EditCustomerDebtDialog } from "./edit-dialog"
import { deleteCustomerDebt } from "./actions"
import { LiveSearch } from "@/components/ui/live-search"

export default async function CreditAccountsPage({
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
    .from("credit_accounts")
    .select("*, customers(name)")
    .order("created_at", { ascending: false })

  if (query) {
    dbQuery = dbQuery.ilike("customer_name_raw", `%${query}%`)
  }

  const { data: credits, error } = await dbQuery

  return (
    <div className="space-y-6 fade-in">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-2xl font-bold tracking-tight text-slate-900">Deynta Macaamiisha</h2>
          <p className="text-slate-500 text-sm mt-0.5">Deymaha macaamiisha lagu leeyahay</p>
        </div>
        <Link href="/credit/new">
          <Button className="bg-slate-900 hover:bg-slate-800 text-white rounded-xl shadow-sm h-10 px-4 font-medium">
            <Plus className="mr-2 h-4 w-4" />
            Ku Dar Deyn Cusub
          </Button>
        </Link>
      </div>

      <div className="max-w-sm">
        <LiveSearch placeholder="Raadi Macmiil..." />
      </div>

      <div className="bg-white rounded-2xl border border-slate-200/80 shadow-sm overflow-hidden">
        <Table>
          <TableHeader>
            <TableRow className="bg-slate-50/80 border-b border-slate-200">
              <TableHead className="font-semibold text-slate-700 pl-6">Macmiilka (Customer)</TableHead>
              <TableHead className="font-semibold text-slate-700">Faahfaahin (Description)</TableHead>
              <TableHead className="font-semibold text-slate-700">Taariikhda</TableHead>
              <TableHead className="text-right font-semibold text-slate-700">Deynta (Total Owed)</TableHead>
              <TableHead className="text-right font-semibold text-slate-700">Haraaga (Remaining)</TableHead>
              <TableHead className="font-semibold text-slate-700">Xaalada (Status)</TableHead>
              <TableHead className="text-right font-semibold text-slate-700 pr-6">Action</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {error && (
              <TableRow>
                <TableCell colSpan={7} className="h-24 text-center text-rose-600 bg-rose-50/50">
                  Cillad: {error.message}
                </TableCell>
              </TableRow>
            )}
            {!error && credits?.length === 0 && (
              <TableRow>
                <TableCell colSpan={7} className="py-16 text-center">
                  <CreditCard className="h-8 w-8 text-slate-300 mx-auto mb-2" />
                  <p className="text-sm text-slate-400">Deyn ma jirto</p>
                </TableCell>
              </TableRow>
            )}
            {credits?.map((credit) => {
              const remaining = Number(credit.amount_owed) - Number(credit.amount_paid);
              return (
                <TableRow key={credit.id} className="table-row-hover border-b border-slate-100 last:border-0">
                  <TableCell className="font-medium text-slate-900 pl-6 py-4">
                    {credit.customers?.name || credit.customer_name_raw}
                  </TableCell>
                  <TableCell className="text-slate-600">{credit.description || "—"}</TableCell>
                  <TableCell className="text-slate-500 text-xs whitespace-nowrap">
                    <div>{new Date(credit.created_at).toLocaleDateString("so-SO", { day: "2-digit", month: "short", year: "numeric", timeZone: "Africa/Nairobi" })}</div>
                    <div className="text-slate-400">{new Date(credit.created_at).toLocaleTimeString("so-SO", { hour: "2-digit", minute: "2-digit", timeZone: "Africa/Nairobi" })}</div>
                  </TableCell>
                  <TableCell className="text-right font-bold text-rose-600">
                    ${Number(credit.amount_owed).toFixed(2)}
                  </TableCell>
                  <TableCell className="text-right font-semibold text-amber-600">
                    ${remaining.toFixed(2)}
                  </TableCell>
                  <TableCell>
                    <Badge
                      className={`rounded-full text-xs font-medium px-2.5 py-0.5 border-0 ${
                        credit.status === 'open'
                          ? 'bg-rose-50 text-rose-700'
                          : credit.status === 'settled'
                          ? 'bg-emerald-50 text-emerald-700'
                          : 'bg-slate-100 text-slate-600'
                      }`}
                    >
                      {credit.status}
                    </Badge>
                  </TableCell>
                  <TableCell className="text-right pr-6">
                    <div className="flex items-center justify-end gap-2">
                      {credit.status === 'open' && (
                        <PayCustomerDebtDialog 
                          creditId={credit.id} 
                          customerName={credit.customers?.name || credit.customer_name_raw}
                          remainingAmount={remaining}
                        />
                      )}
                      
                      <EditCustomerDebtDialog debt={credit} />

                      {isAdmin && (
                        <form>
                          <Button 
                            formAction={async () => {
                              "use server"
                              await deleteCustomerDebt(credit.id)
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
