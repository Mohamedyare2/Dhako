import { createClient } from "@/lib/supabase/server"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Badge } from "@/components/ui/badge"
import { CreditCard, ArrowLeft, User, Phone } from "lucide-react"
import Link from "next/link"
import PayCustomerDebtDialog from "../../pay-dialog"
import { EditCustomerDebtDialog } from "../../edit-dialog"
import { notFound } from "next/navigation"

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

export default async function CustomerProfilePage({ params }: { params: { id: string } }) {
  const supabase = createClient()
  
  // The id param can be: UUID (customer_id) or encoded raw name
  const rawId = params.id  // Already URL-decoded by Next.js
  const decodedId = decodeURIComponent(rawId)

  const isUUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(decodedId)

  // Determine customer info and identifiers
  let targetName = decodedId
  let targetPhone: string | null = null
  let customerUUID: string | null = isUUID ? decodedId : null

  if (isUUID) {
    const { data: customerRecord } = await supabase
      .from("customers")
      .select("id, name, phone")
      .eq("id", decodedId)
      .maybeSingle()

    if (customerRecord) {
      targetName = customerRecord.name
      targetPhone = customerRecord.phone
    }
  } else {
    const { data: customerRecord } = await supabase
      .from("customers")
      .select("id, name, phone")
      .ilike("name", decodedId.trim())
      .maybeSingle()

    if (customerRecord) {
      customerUUID = customerRecord.id
      targetName = customerRecord.name
      targetPhone = customerRecord.phone
    }
  }

  // Build query to find ALL credit records for this customer
  let dbQuery = supabase
    .from("credit_accounts")
    .select("*, customers(name, phone)")
    .order("created_at", { ascending: false })

  if (customerUUID && targetName && targetName !== customerUUID) {
    dbQuery = dbQuery.or(`customer_id.eq.${customerUUID},customer_name_raw.ilike.${targetName.trim()}`)
  } else if (customerUUID) {
    dbQuery = dbQuery.eq("customer_id", customerUUID)
  } else {
    dbQuery = dbQuery.ilike("customer_name_raw", targetName.trim())
  }

  const { data: credits, error } = await dbQuery

  // If no results and customer does not exist in customers table, return 404
  if (!error && (!credits || credits.length === 0)) {
    if (isUUID && !targetPhone && targetName === decodedId) {
      notFound()
    }
  }

  // Determine final customer display name and phone
  const customerName =
    targetName !== decodedId
      ? targetName
      : credits?.[0]?.customers?.name ||
        credits?.[0]?.customer_name_raw ||
        decodedId

  const customerPhone = targetPhone || credits?.[0]?.customers?.phone || null

  // Calculate per-customer totals
  const totalOwed = credits?.reduce((sum, c) => sum + Number(c.amount_owed), 0) ?? 0
  const totalPaid = credits?.reduce((sum, c) => sum + Number(c.amount_paid), 0) ?? 0
  const totalRemaining = totalOwed - totalPaid
  const openDebts = credits?.filter(c => c.status !== "settled") ?? []

  return (
    <div className="space-y-6 fade-in">
      {/* Header with back nav */}
      <div className="flex flex-col sm:flex-row sm:items-start justify-between gap-4">
        <div>
          <div className="flex items-center gap-2 mb-2">
            <Link
              href="/credit"
              className="h-8 w-8 flex items-center justify-center rounded-lg border border-slate-200 text-slate-500 hover:text-slate-900 hover:border-slate-300 transition-colors"
            >
              <ArrowLeft className="h-4 w-4" />
            </Link>
            <h2 className="text-2xl font-bold tracking-tight text-slate-900">
              Profile: {customerName}
            </h2>
          </div>
          <div className="flex items-center gap-4 ml-10">
            <div className="flex items-center gap-1.5 text-slate-500">
              <User className="h-3.5 w-3.5" />
              <span className="text-sm">Macmiil</span>
            </div>
            {customerPhone && (
              <div className="flex items-center gap-1.5 text-slate-500">
                <Phone className="h-3.5 w-3.5" />
                <span className="text-sm">{customerPhone}</span>
              </div>
            )}
            <span className="text-sm text-slate-400">
              {credits?.length ?? 0} diiwaanle
            </span>
          </div>
        </div>
      </div>

      {/* Summary Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <div className="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm">
          <p className="text-sm font-medium text-slate-500">Wadarta Deynta</p>
          <p className="text-2xl font-bold text-rose-600 mt-1">${totalOwed.toFixed(2)}</p>
          <p className="text-xs text-slate-400 mt-1">{credits?.length ?? 0} deyn oo dhan</p>
        </div>
        <div className="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm">
          <p className="text-sm font-medium text-slate-500">Wadarta La Bixiyay</p>
          <p className="text-2xl font-bold text-emerald-600 mt-1">${totalPaid.toFixed(2)}</p>
          <p className="text-xs text-slate-400 mt-1">La bixiyay guud ahaan</p>
        </div>
        <div className="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm">
          <p className="text-sm font-medium text-slate-500">Haraaga (Outstanding)</p>
          <p className="text-2xl font-bold text-amber-600 mt-1">${totalRemaining.toFixed(2)}</p>
          <p className="text-xs text-slate-400 mt-1">{openDebts.length} deyn oo wali furan</p>
        </div>
      </div>

      {/* Debt History Table */}
      <div className="bg-white rounded-2xl border border-slate-200/80 shadow-sm overflow-hidden">
        <div className="px-6 py-4 border-b border-slate-100">
          <h3 className="font-semibold text-slate-900">Taariikhda Deymaha</h3>
          <p className="text-xs text-slate-500 mt-0.5">Dhammaan deymaha iyo lacag bixinta macmiilkan</p>
        </div>
        <Table>
          <TableHeader>
            <TableRow className="bg-slate-50/80 border-b border-slate-200">
              <TableHead className="font-semibold text-slate-700 pl-6">Faahfaahin</TableHead>
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
                <TableCell colSpan={7} className="h-24 text-center text-rose-600 bg-rose-50/50">
                  ⚠️ Cillad: {error.message}
                </TableCell>
              </TableRow>
            )}
            {!error && (!credits || credits.length === 0) && (
              <TableRow>
                <TableCell colSpan={7} className="py-16 text-center">
                  <CreditCard className="h-8 w-8 text-slate-300 mx-auto mb-2" />
                  <p className="text-sm text-slate-400">Macmiilkan deyn laguma lahan</p>
                </TableCell>
              </TableRow>
            )}
            {credits?.map((credit) => {
              const remaining = Number(credit.amount_owed) - Number(credit.amount_paid)
              return (
                <TableRow key={credit.id} className="table-row-hover border-b border-slate-100 last:border-0">
                  <TableCell className="text-slate-700 pl-6 py-4 max-w-[220px] truncate">
                    {credit.description || "—"}
                  </TableCell>
                  <TableCell className="text-slate-500 text-xs whitespace-nowrap">
                    <div className="font-medium text-slate-700">{formatDate(credit.created_at)}</div>
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
                          customerName={customerName}
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
