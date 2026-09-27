import { createClient } from "@/lib/supabase/server"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Users, Trash2 } from "lucide-react"
import { LiveSearch } from "@/components/ui/live-search"
import { AddCustomerDialog, EditCustomerDialog } from "./customer-dialogs"
import { Button } from "@/components/ui/button"
import { deleteCustomer } from "./actions"

export default async function CustomersPage({
  searchParams,
}: {
  searchParams: { q?: string }
}) {
  const supabase = createClient()
  const query = searchParams.q || ""

  // Check admin
  const { data: { user } } = await supabase.auth.getUser()
  const { data: profile } = await supabase.from("profiles").select("role").eq("id", user?.id).single()
  const isAdmin = profile?.role === 'admin'

  let dbQuery = supabase
    .from("customers")
    .select("*")
    .order("created_at", { ascending: false })

  if (query) {
    dbQuery = dbQuery.ilike("name", `%${query}%`)
  }

  const { data: customers, error } = await dbQuery

  return (
    <div className="space-y-6 fade-in">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-2xl font-bold tracking-tight text-slate-900">Macaamiisha (Customers)</h2>
          <p className="text-slate-500 text-sm mt-0.5">Liiska macaamiisha meheradda</p>
        </div>
        <AddCustomerDialog />
      </div>

      <div className="max-w-sm">
        <LiveSearch placeholder="Raadi Macaamiil..." />
      </div>

      <div className="bg-white rounded-2xl border border-slate-200/80 shadow-sm overflow-hidden">
        <Table>
          <TableHeader>
            <TableRow className="bg-slate-50/80 border-b border-slate-200">
              <TableHead className="font-semibold text-slate-700 pl-6">Magaca (Name)</TableHead>
              <TableHead className="font-semibold text-slate-700">Telefoonka (Phone)</TableHead>
              <TableHead className="font-semibold text-slate-700">Faahfaahin (Notes)</TableHead>
              <TableHead className="font-semibold text-slate-700 text-right pr-6">Action</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {error && (
              <TableRow>
                <TableCell colSpan={4} className="h-24 text-center text-rose-600 bg-rose-50/50">
                  Cillad: {error.message}
                </TableCell>
              </TableRow>
            )}
            {!error && customers?.length === 0 && (
              <TableRow>
                <TableCell colSpan={4} className="py-16 text-center">
                  <Users className="h-8 w-8 text-slate-300 mx-auto mb-2" />
                  <p className="text-sm text-slate-400">Macaamiil ma jiraan</p>
                </TableCell>
              </TableRow>
            )}
            {customers?.map((c) => (
              <TableRow key={c.id} className="table-row-hover border-b border-slate-100 last:border-0">
                <TableCell className="pl-6 py-4">
                  <div className="flex items-center gap-3">
                    <div className="w-8 h-8 rounded-full bg-slate-100 flex items-center justify-center text-sm font-semibold text-slate-600 shrink-0">
                      {c.name?.charAt(0)?.toUpperCase() || "?"}
                    </div>
                    <span className="font-medium text-slate-900">{c.name}</span>
                  </div>
                </TableCell>
                <TableCell className="text-slate-600 font-medium">{c.phone || "—"}</TableCell>
                <TableCell className="text-slate-500 text-sm">{c.notes || "—"}</TableCell>
                <TableCell className="text-right pr-6">
                  <div className="flex items-center justify-end gap-2">
                    <EditCustomerDialog customer={c} />
                    {isAdmin && (
                      <form>
                        <Button 
                          formAction={async () => {
                            "use server"
                            await deleteCustomer(c.id)
                          }} 
                          variant="outline" 
                          size="sm" 
                          className="rounded-lg border-rose-200 text-rose-600 hover:bg-rose-50 hover:border-rose-300 h-8 px-2"
                          title="Delete Customer"
                        >
                          <Trash2 className="h-3.5 w-3.5" />
                        </Button>
                      </form>
                    )}
                  </div>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
    </div>
  )
}
