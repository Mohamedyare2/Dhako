import { createClient } from "@/lib/supabase/server"
import { Button } from "@/components/ui/button"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Plus } from "lucide-react"

export default async function CategoriesPage() {
  const supabase = createClient()
  
  const { data: categories, error } = await supabase
    .from("categories")
    .select("*")
    .order("name_so", { ascending: true })

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-2xl font-bold tracking-tight">Qaybaha (Categories)</h2>
          <p className="text-slate-500">Noocyada kala duwan ee alaabta (Filters, Oils, etc.)</p>
        </div>
        <Button className="bg-slate-900 hover:bg-slate-800">
          <Plus className="mr-2 h-4 w-4" />
          Ku Dar Qayb
        </Button>
      </div>

      <div className="rounded-md border bg-white">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Magaca Af-Soomaali (Somali Name)</TableHead>
              <TableHead>Magaca English (English Name)</TableHead>
              <TableHead>Faahfaahin (Description)</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {error && (
              <TableRow>
                <TableCell colSpan={3} className="text-center text-red-500">Cillad: {error.message}</TableCell>
              </TableRow>
            )}
            {!error && categories?.length === 0 && (
              <TableRow>
                <TableCell colSpan={3} className="text-center text-slate-500">Qaybaha lama helin.</TableCell>
              </TableRow>
            )}
            {categories?.map((cat) => (
              <TableRow key={cat.id}>
                <TableCell className="font-medium">{cat.name_so}</TableCell>
                <TableCell>{cat.name_en || "-"}</TableCell>
                <TableCell className="text-slate-500">{cat.description || "-"}</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
    </div>
  )
}
