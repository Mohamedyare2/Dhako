import { createClient } from "@/lib/supabase/server"
import { Button } from "@/components/ui/button"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Badge } from "@/components/ui/badge"
import { Plus, Trash2, CreditCard } from "lucide-react"
import Link from "next/link"
import PayCustomerDebtDialog from "./pay-dialog"
import { EditCustomerDebtDialog } from "./edit-dialog"
import { deleteCustomerDebt } from "./actions"
import { CreditFilters } from "./credit-filters"

function formatDate(dateStr: string) {
  return new Date(dateStr).toLocaleDateString("en-GB", {
    day: "2-digit",
    month: "2-digit",
    year: "numeric",
    timeZone: "Africa/Nairobi",
  })
}

function formatTime(dateStr: string) {
  return new Date(dateStr).toLocaleTimeString("en-GB", {
    hour: "2-digit",
    minute: "2-digit",
    timeZone: "Africa/Nairobi",
  })
}

export default async function CreditAccountsPage({
  searchParams,
}: {
  searchParams: { q?: string; date?: string }
}) {
  const supabase = createClient()
  const query = searchParams.q || ""
  const filterDate = searchParams.date || ""

  // Verify admin role
  const { data: { user } } = await supabase.auth.getUser()
  let isAdmin = false
  if (user) {
    const { data: profile } = await supabase.from("profiles").select("role").eq("id", user.id).single()
    isAdmin = profile?.role === "admin"
  }

  let dbQuery = supabase
    .from("credit_accounts")
    .select("*, customers(name)")
    .order("created_at", { ascending: false })

  if (query) {
    // Search both raw name and linked customer name
    dbQuery = dbQuery.ilike("customer_name_raw", `%${query}%`)
  }

  if (filterDate) {
    dbQuery = dbQuery
      .gte("created_at", `${filterDate}T00:00:00+03:00`)
      .lte("created_at", `${filterDate}T23:59:59+03:00`)
  }

  const { data: credits, error } = await dbQuery

  // Calculate totals from ALL open debts (not just filtered ones) for the summary cards
  const { data: allOpenCredits } = await supabase
    .from("credit_accounts")
    .select("amount_owed, amount_paid")
    .neq("status", "settled")

  const totalOwed = allOpenCredits?.reduce((sum, c) => sum + Number(c.amount_owed), 0) ?? 0
  const totalPaid = allOpenCredits?.reduce((sum, c) => sum + Number(c.amount_paid), 0) ?? 0
  const totalRemaining = totalOwed - totalPaid

  return (
    <div className="space-y-6 fade-in">
      {/* Header */}
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

      {/* Summary Cards - show totals for ALL open debts */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <div className="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm">
          <p className="text-sm font-medium text-slate-500">Wadarta Deynta (Total Owed)</p>
          <p className="text-2xl font-bold text-rose-600 mt-1">${totalOwed.toFixed(2)}</p>
          <p className="text-xs text-slate-400 mt-1">Dhammaan deymaha furan</p>
        </div>
        <div className="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm">
          <p className="text-sm font-medium text-slate-500">Wadarta La Bixiyay (Total Paid)</p>
          <p className="text-2xl font-bold text-emerald-600 mt-1">${totalPaid.toFixed(2)}</p>
          <p className="text-xs text-slate-400 mt-1">La bixiyay ilaa iyo hadda</p>
        </div>
        <div className="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm">
          <p className="text-sm font-medium text-slate-500">Haraaga Guud (Outstanding)</p>
          <p className="text-2xl font-bold text-amber-600 mt-1">${totalRemaining.toFixed(2)}</p>
          <p className="text-xs text-slate-400 mt-1">Wali la bixin</p>
        </div>
      </div>

      {/* Filters */}
      <CreditFilters currentDate={filterDate} />

      {/* Table */}
      <div className="bg-white rounded-2xl border border-slate-200/80 shadow-sm overflow-hidden">
        <Table>
          <TableHeader>
            <TableRow className="bg-slate-50/80 border-b border-slate-200">
              <TableHead className="font-semibold text-slate-700 pl-6">Macmiilka</TableHead>
              <TableHead className="font-semibold text-slate-700">Faahfaahin</TableHead>
              <TableHead className="font-semibold text-slate-700">Taariikhda</TableHead>
              <TableHead className="text-right font-semibold text-slate-700">Deynta</TableHead>
              <TableHead className="text-right font-semibold text-slate-700">La Bixiyay</TableHead>
              <TableHead className="text-right font-semibold text-slate-700">Haraaga</TableHead>
              <TableHead className="font-semibold text-slate-700">Xaalada</TableHead>
              <TableHead className="text-right font-semibold text-slate-700 pr-6">Ficil</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {error && (
              <TableRow>
                <TableCell colSpan={8} className="h-24 text-center text-rose-600 bg-rose-50/50">
                  ⚠️ Cillad: {error.message}
                </TableCell>
              </TableRow>
            )}
            {!error && credits?.length === 0 && (
              <TableRow>
                <TableCell colSpan={8} className="py-16 text-center">
                  <CreditCard className="h-8 w-8 text-slate-300 mx-auto mb-2" />
                  <p className="text-sm text-slate-400">
                    {filterDate ? `${filterDate} maalinta deyn ma jirto` : query ? "Macmiil la mid ah lama helin" : "Deyn ma jirto"}
                  </p>
                </TableCell>
              </TableRow>
            )}
            {credits?.map((credit) => {
              const remaining = Number(credit.amount_owed) - Number(credit.amount_paid)
              // Build a safe customer identifier for the profile link
              // Prefer customer_id (UUID) for linked customers, fallback to name, then credit id
              const customerIdentifier =
                credit.customer_id ??
                (credit.customer_name_raw ? encodeURIComponent(credit.customer_name_raw) : null)
              
              const displayName = credit.customers?.name || credit.customer_name_raw || "Macmiil Caadi"

              return (
                <TableRow key={credit.id} className="table-row-hover border-b border-slate-100 last:border-0">
                  <TableCell className="pl-6 py-4">
                    {customerIdentifier ? (
                      <Link
                        href={`/credit/customer/${customerIdentifier}`}
                        className="inline-flex items-center gap-2.5 font-medium text-blue-600 hover:text-blue-800 transition-all group"
                        title={`Guji si aad u furto Profile-ka ${displayName}`}
                      >
                        <div className="w-8 h-8 rounded-full bg-blue-50 border border-blue-200/80 text-blue-700 flex items-center justify-center text-xs font-bold shadow-xs group-hover:bg-blue-600 group-hover:text-white group-hover:border-blue-600 transition-all shrink-0">
                          {displayName.charAt(0).toUpperCase()}
                        </div>
                        <div className="flex flex-col">
                          <span className="font-semibold text-slate-900 group-hover:text-blue-600 leading-tight transition-colors">
                            {displayName}
                          </span>
                          <span className="text-[11px] text-blue-600 font-medium group-hover:underline flex items-center gap-0.5 mt-0.5">
                            Profile-ka & Taariikhda →
                          </span>
                        </div>
                      </Link>
                    ) : (
                      <span className="font-medium text-slate-800">{displayName}</span>
                    )}
                  </TableCell>
                  <TableCell className="text-slate-600 max-w-[200px] truncate">{credit.description || "—"}</TableCell>
                  <TableCell className="text-slate-500 text-xs whitespace-nowrap">
                    <div className="font-medium">{formatDate(credit.created_at)}</div>
                    <div className="text-slate-400">{formatTime(credit.created_at)}</div>
                  </TableCell>
                  <TableCell className="text-right font-bold text-rose-600">
                    ${Number(credit.amount_owed).toFixed(2)}
                  </TableCell>
                  <TableCell className="text-right font-medium text-emerald-600">
                    ${Number(credit.amount_paid).toFixed(2)}
                  </TableCell>
                  <TableCell className="text-right font-semibold text-amber-600">
                    ${remaining.toFixed(2)}
                  </TableCell>
                  <TableCell>
                    <Badge
                      className={`rounded-full text-xs font-medium px-2.5 py-0.5 border-0 ${
                        credit.status === "open"
                          ? "bg-rose-50 text-rose-700"
                          : credit.status === "settled"
                          ? "bg-emerald-50 text-emerald-700"
                          : "bg-slate-100 text-slate-600"
                      }`}
                    >
                      {credit.status === "open" ? "Furan" : credit.status === "settled" ? "La Bixiyay" : credit.status}
                    </Badge>
                  </TableCell>
                  <TableCell className="text-right pr-6">
                    <div className="flex items-center justify-end gap-1.5">
                      {credit.status !== "settled" && (
                        <PayCustomerDebtDialog
                          creditId={credit.id}
                          customerName={displayName}
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
                            title="Tirtir Deynta"
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
