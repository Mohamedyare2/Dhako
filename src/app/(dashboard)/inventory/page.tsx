import { createClient } from "@/lib/supabase/server"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Badge } from "@/components/ui/badge"

export default async function InventoryPage() {
  const supabase = createClient()
  
  const { data: inventory, error } = await supabase
    .from("products")
    .select("id, name, part_code, quantity_on_hand, min_stock_level")
    .order("quantity_on_hand", { ascending: true })
    .limit(100)

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-2xl font-bold tracking-tight">Inventory</h2>
        <p className="text-slate-500">Monitor stock levels and reorder points</p>
      </div>

      <div className="rounded-md border bg-white">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Product</TableHead>
              <TableHead>Part Code</TableHead>
              <TableHead className="text-right">Current Stock</TableHead>
              <TableHead className="text-right">Min Level</TableHead>
              <TableHead>Status</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {error && (
              <TableRow>
                <TableCell colSpan={5} className="text-center text-red-500">
                  {error.message}
                </TableCell>
              </TableRow>
            )}
            {inventory?.map((item) => (
              <TableRow key={item.id}>
                <TableCell className="font-medium">{item.name}</TableCell>
                <TableCell>{item.part_code || "-"}</TableCell>
                <TableCell className="text-right font-bold">{item.quantity_on_hand}</TableCell>
                <TableCell className="text-right text-slate-500">{item.min_stock_level}</TableCell>
                <TableCell>
                  {item.quantity_on_hand <= 0 ? (
                    <Badge variant="destructive">Out of Stock</Badge>
                  ) : item.quantity_on_hand <= item.min_stock_level ? (
                    <Badge variant="outline" className="bg-amber-100 text-amber-800 border-amber-200">Low Stock</Badge>
                  ) : (
                    <Badge variant="secondary" className="bg-green-100 text-green-800 hover:bg-green-100">In Stock</Badge>
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
