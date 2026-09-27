import { createClient } from "@/lib/supabase/server"
import { Button } from "@/components/ui/button"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Badge } from "@/components/ui/badge"
import { Plus, Trash2, Edit, Package } from "lucide-react"
import Link from "next/link"
import { deleteProduct } from "./actions"
import { LiveSearch } from "@/components/ui/live-search"

export default async function ProductsPage({
  searchParams,
}: {
  searchParams: { q?: string }
}) {
  const supabase = createClient()
  const query = searchParams.q || ""

  // Get current user role
  const { data: { user } } = await supabase.auth.getUser()
  let isAdmin = false
  if (user) {
    const { data: profile } = await supabase.from("profiles").select("role").eq("id", user.id).single()
    isAdmin = profile?.role === 'admin'
  }

  let dbQuery = supabase
    .from("products")
    .select("*, categories(name_so)")
    .order("created_at", { ascending: false })
    .limit(50)

  if (query) {
    dbQuery = dbQuery.ilike("name", `%${query}%`)
  }

  const { data: products, error } = await dbQuery

  return (
    <div className="space-y-6 fade-in">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-2xl font-bold tracking-tight text-slate-900">Products</h2>
          <p className="text-slate-500 text-sm mt-0.5">Manage your inventory catalog</p>
        </div>
        {isAdmin && (
          <Link href="/products/new">
            <Button className="bg-slate-900 hover:bg-slate-800 text-white rounded-xl shadow-sm h-10 px-4 font-medium">
              <Plus className="mr-2 h-4 w-4" />
              Add Product
            </Button>
          </Link>
        )}
      </div>

      <div className="max-w-sm">
        <LiveSearch placeholder="Search products..." />
      </div>

      <div className="bg-white rounded-2xl border border-slate-200/80 shadow-sm overflow-hidden">
        <Table>
          <TableHeader>
            <TableRow className="bg-slate-50/80 border-b border-slate-200">
              <TableHead className="font-semibold text-slate-700 pl-6">Product Name</TableHead>
              <TableHead className="font-semibold text-slate-700">Category</TableHead>
              <TableHead className="font-semibold text-slate-700">Part Code</TableHead>
              {isAdmin && <TableHead className="text-right font-semibold text-slate-700">Cost Price</TableHead>}
              <TableHead className="text-right font-semibold text-slate-700">Unit Price</TableHead>
              {isAdmin && <TableHead className="text-right font-semibold text-emerald-600">Faa&apos;ido</TableHead>}
              <TableHead className="text-right font-semibold text-slate-700">Stock</TableHead>
              <TableHead className="font-semibold text-slate-700">Status</TableHead>
              {isAdmin && <TableHead className="text-right font-semibold text-slate-700 pr-6">Actions</TableHead>}
            </TableRow>
          </TableHeader>
          <TableBody>
            {error && (
              <TableRow>
                <TableCell colSpan={isAdmin ? 9 : 6} className="h-24 text-center text-rose-600 bg-rose-50/50">
                  ⚠️ Failed to load products: {error.message}
                </TableCell>
              </TableRow>
            )}
            {!error && products?.length === 0 && (
              <TableRow>
                <TableCell colSpan={isAdmin ? 9 : 6} className="py-16 text-center">
                  <Package className="h-8 w-8 text-slate-300 mx-auto mb-2" />
                  <p className="text-sm text-slate-400">No products found</p>
                </TableCell>
              </TableRow>
            )}
            {products?.map((product) => (
              <TableRow key={product.id} className="table-row-hover border-b border-slate-100 last:border-0">
                <TableCell className="font-medium text-slate-900 pl-6 py-4">{product.name}</TableCell>
                <TableCell className="text-slate-600">{product.categories?.name_so || "General"}</TableCell>
                <TableCell className="text-slate-500 font-mono text-xs">{product.part_code || "—"}</TableCell>
                
                {isAdmin && (
                  <TableCell className="text-right text-slate-500">${Number(product.cost_price || 0).toFixed(2)}</TableCell>
                )}
                
                <TableCell className="text-right font-semibold text-slate-900">${Number(product.selling_price || 0).toFixed(2)}</TableCell>
                
                {isAdmin && (
                  <TableCell className="text-right font-bold text-emerald-600">
                    ${(Number(product.selling_price || 0) - Number(product.cost_price || 0)).toFixed(2)}
                  </TableCell>
                )}

                <TableCell className="text-right">
                  <div className="flex items-center justify-end gap-2 font-medium">
                    <span className={product.quantity_on_hand <= product.min_stock_level ? "text-amber-600 font-bold" : "text-slate-700"}>
                      {product.quantity_on_hand}
                    </span>
                    {product.quantity_on_hand <= product.min_stock_level && (
                      <span className="h-2 w-2 rounded-full bg-amber-500" title="Low Stock" />
                    )}
                  </div>
                </TableCell>
                
                <TableCell>
                  <Badge
                    className={`rounded-full text-xs font-medium px-2.5 py-0.5 border-0 ${
                      product.status === 'active'
                        ? 'bg-emerald-50 text-emerald-700'
                        : 'bg-slate-100 text-slate-600'
                    }`}
                  >
                    {product.status}
                  </Badge>
                </TableCell>
                
                {isAdmin && (
                  <TableCell className="text-right pr-6">
                    <form className="flex items-center justify-end gap-1">
                       <Link href={`/products/${product.id}`}>
                         <Button type="button" variant="ghost" size="icon" className="h-8 w-8 text-slate-500 hover:text-blue-600 hover:bg-blue-50 rounded-lg">
                           <Edit className="h-4 w-4" />
                         </Button>
                       </Link>
                       <Button formAction={async () => {
                         "use server"
                         await deleteProduct(product.id)
                       }} variant="ghost" size="icon" className="h-8 w-8 text-slate-500 hover:text-rose-600 hover:bg-rose-50 rounded-lg">
                         <Trash2 className="h-4 w-4" />
                       </Button>
                    </form>
                  </TableCell>
                )}
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
    </div>
  )
}
