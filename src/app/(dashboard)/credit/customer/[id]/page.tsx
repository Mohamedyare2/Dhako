import { createClient } from "@/lib/supabase/server"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Badge } from "@/components/ui/badge"
import { CreditCard, ArrowLeft } from "lucide-react"
import Link from "next/link"
import PayCustomerDebtDialog from "../../pay-dialog"
import { EditCustomerDebtDialog } from "../../edit-dialog"

export default async function CustomerProfilePage({ params }: { params: { id: string } }) {
  const supabase = createClient()
  const decodedId = decodeURIComponent(params.id)
  
  // We check if the ID is a UUID (meaning a customer_id) or a raw name string
  const isUUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(decodedId);
  
  let dbQuery = supabase
    .from("credit_accounts")
    .select("*, customers(name)")
    .order("created_at", { ascending: false })

  if (isUUID) {
    dbQuery = dbQuery.eq("customer_id", decodedId)
  } else {
    dbQuery = dbQuery.eq("customer_name_raw", decodedId)
  }

  const { data: credits, error } = await dbQuery

  const customerName = credits?.[0]?.customers?.name || credits?.[0]?.customer_name_raw || decodedId

  // Calculate totals for this specific customer
  const totalOwed = credits?.reduce((sum, credit) => sum + Number(credit.amount_owed), 0) || 0
  const totalPaid = credits?.reduce((sum, credit) => sum + Number(credit.amount_paid), 0) || 0
  const totalRemaining = totalOwed - totalPaid

  return (
    <div className="space-y-6 fade-in">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-2 mb-2">
            <Link href="/credit" className="text-slate-500 hover:text-slate-900 transition-colors">
              <ArrowLeft className="h-5 w-5" />
            </Link>
            <h2 className="text-2xl font-bold tracking-tight text-slate-900">Profile-ka: {customerName}</h2>
          </div>
          <p className="text-slate-500 text-sm mt-0.5 ml-7">Taariikhda deymaha macmiilkan</p>
        </div>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <div className="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm flex flex-col justify-center">
          <p className="text-sm font-medium text-slate-500">Wadarta Deynta</p>
          <p className="text-2xl font-bold text-rose-600 mt-1">${totalOwed.toFixed(2)}</p>
        </div>
        <div className="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm flex flex-col justify-center">
          <p className="text-sm font-medium text-slate-500">Wadarta La Bixiyay</p>
          <p className="text-2xl font-bold text-emerald-600 mt-1">${totalPaid.toFixed(2)}</p>
        </div>
        <div className="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm flex flex-col justify-center">
          <p className="text-sm font-medium text-slate-500">Haraaga Guud</p>
          <p className="text-2xl font-bold text-amber-600 mt-1">${totalRemaining.toFixed(2)}</p>
        </div>
      </div>

      <div className="bg-white rounded-2xl border border-slate-200/80 shadow-sm overflow-hidden mt-6">
        <Table>
          <TableHeader>
            <TableRow className="bg-slate-50/80 border-b border-slate-200">
              <TableHead className="font-semibold text-slate-700 pl-6">Faahfaahin (Description)</TableHead>
              <TableHead className="font-semibold text-slate-700">Taariikhda</TableHead>
              <TableHead className="text-right font-semibold text-slate-700">Deynta</TableHead>
              <TableHead className="text-right font-semibold text-slate-700">La Bixiyay</TableHead>
              <TableHead className="text-right font-semibold text-slate-700">Haraaga</TableHead>
              <TableHead className="font-semibold text-slate-700">Xaalada</TableHead>
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
                  <p className="text-sm text-slate-400">Deyn laguma laha</p>
                </TableCell>
              </TableRow>
            )}
            {credits?.map((credit) => {
              const remaining = Number(credit.amount_owed) - Number(credit.amount_paid);
              return (
                <TableRow key={credit.id} className="table-row-hover border-b border-slate-100 last:border-0">
                  <TableCell className="text-slate-600 pl-6">{credit.description || "—"}</TableCell>
                  <TableCell className="text-slate-500 text-xs whitespace-nowrap">
                    <div>{new Date(credit.created_at).toLocaleDateString("so-SO", { day: "2-digit", month: "short", year: "numeric", timeZone: "Africa/Nairobi" })}</div>
                    <div className="text-slate-400">{new Date(credit.created_at).toLocaleTimeString("so-SO", { hour: "2-digit", minute: "2-digit", timeZone: "Africa/Nairobi" })}</div>
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
