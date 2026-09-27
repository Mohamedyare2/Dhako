import { createClient } from "@/lib/supabase/server"
import { Package, ShoppingCart, AlertTriangle, CreditCard, TrendingUp, ArrowUpRight, ArrowDownRight } from "lucide-react"

export default async function DashboardPage() {
  const supabase = createClient()

  // Fetch live stats
  const [
    { count: totalProducts },
    { count: lowStockCount },
    { data: todaySaleItemsData },
    { data: openCreditData },
    { data: recentSales },
    { data: lowStockItems },
  ] = await Promise.all([
    supabase.from("products").select("*", { count: "exact", head: true }).eq("status", "active"),
    supabase.from("products").select("*", { count: "exact", head: true }).lt("quantity_on_hand", 5),
    supabase.from("sale_items").select("quantity, unit_price, products(cost_price)").gte("created_at", new Date().toISOString().split("T")[0]),
    supabase.from("credit_accounts").select("amount_owed, amount_paid").eq("status", "open"),
    supabase.from("sales").select("*, customers(name)").order("sale_date", { ascending: false }).limit(6),
    supabase.from("products").select("name, quantity_on_hand, min_stock_level").lt("quantity_on_hand", 5).limit(6),
  ])

  // Calculate profit: (selling_price - cost_price) * quantity
  // Using an explicit type for 'r' since TypeScript might not infer the inner joined 'products' type properly
  const todayProfit = todaySaleItemsData?.reduce((sum, r: any) => {
    const cost = r.products?.cost_price || 0;
    const profitPerItem = Number(r.unit_price) - Number(cost);
    return sum + (profitPerItem * Number(r.quantity));
  }, 0) ?? 0;

  const openCredit = openCreditData?.reduce((s, r) => s + (Number(r.amount_owed) - Number(r.amount_paid)), 0) ?? 0

  const stats = [
    {
      title: "Total Products",
      value: totalProducts ?? 0,
      suffix: "",
      desc: "Active items in inventory",
      icon: Package,
      iconBg: "bg-blue-50",
      iconColor: "text-blue-600",
      trend: null,
    },
    {
      title: "Low Stock Alerts",
      value: lowStockCount ?? 0,
      suffix: "",
      desc: "Items below minimum level",
      icon: AlertTriangle,
      iconBg: "bg-amber-50",
      iconColor: "text-amber-600",
      trend: "warn",
    },
    {
      title: "Faa'iidada Maanta",
      value: todayProfit.toFixed(2),
      suffix: "$",
      desc: "Wadarta faa'iidada maanta",
      icon: TrendingUp,
      iconBg: "bg-emerald-50",
      iconColor: "text-emerald-600",
      trend: "up",
    },
    {
      title: "Outstanding Credit",
      value: openCredit.toFixed(2),
      suffix: "$",
      desc: "Uncollected customer debt",
      icon: CreditCard,
      iconBg: "bg-rose-50",
      iconColor: "text-rose-600",
      trend: "down",
    },
  ]

  return (
    <div className="space-y-8 fade-in">
      {/* Page Header */}
      <div>
        <h2 className="text-2xl font-bold text-slate-900 tracking-tight">Dashboard Overview</h2>
        <p className="text-slate-500 mt-0.5">Xaaladda guud ee meheradda maanta</p>
      </div>

      {/* Stats Grid */}
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {stats.map((stat) => (
          <div
            key={stat.title}
            className="bg-white rounded-2xl border border-slate-200/80 p-5 shadow-sm card-hover"
          >
            <div className="flex items-start justify-between mb-4">
              <div className={`stat-card-icon ${stat.iconBg}`}>
                <stat.icon className={`h-5 w-5 ${stat.iconColor}`} />
              </div>
              {stat.trend === "up" && (
                <span className="flex items-center gap-1 text-xs font-medium text-emerald-600 bg-emerald-50 px-2 py-1 rounded-full">
                  <ArrowUpRight className="h-3 w-3" /> Live
                </span>
              )}
              {stat.trend === "warn" && (
                <span className="flex items-center gap-1 text-xs font-medium text-amber-600 bg-amber-50 px-2 py-1 rounded-full">
                  <AlertTriangle className="h-3 w-3" /> Alert
                </span>
              )}
              {stat.trend === "down" && (
                <span className="flex items-center gap-1 text-xs font-medium text-rose-600 bg-rose-50 px-2 py-1 rounded-full">
                  <ArrowDownRight className="h-3 w-3" /> Open
                </span>
              )}
            </div>
            <div className="text-2xl font-bold text-slate-900">
              {stat.suffix}{String(stat.value)}
            </div>
            <p className="text-xs text-slate-500 mt-1">{stat.title}</p>
            <p className="text-xs text-slate-400 mt-0.5">{stat.desc}</p>
          </div>
        ))}
      </div>

      {/* Two Column Section */}
      <div className="grid gap-6 lg:grid-cols-7">
        {/* Recent Sales */}
        <div className="lg:col-span-4 bg-white rounded-2xl border border-slate-200/80 shadow-sm overflow-hidden">
          <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100">
            <div>
              <h3 className="font-semibold text-slate-900">Iibkii Ugu Dambeeyay</h3>
              <p className="text-xs text-slate-500 mt-0.5">6 iib oo ugu dambeeyay</p>
            </div>
            <a href="/sales" className="text-xs font-medium text-blue-600 hover:text-blue-800 transition-colors flex items-center gap-1">
              View all <ArrowUpRight className="h-3 w-3" />
            </a>
          </div>
          <div className="divide-y divide-slate-100">
            {!recentSales || recentSales.length === 0 ? (
              <div className="px-6 py-10 text-center">
                <ShoppingCart className="h-8 w-8 text-slate-300 mx-auto mb-2" />
                <p className="text-sm text-slate-400">Iib ma jirto weli</p>
              </div>
            ) : (
              recentSales.map((sale) => (
                <div key={sale.id} className="flex items-center justify-between px-6 py-3.5 table-row-hover">
                  <div className="flex items-center gap-3">
                    <div className="w-8 h-8 rounded-full bg-slate-100 flex items-center justify-center shrink-0">
                      <ShoppingCart className="h-3.5 w-3.5 text-slate-500" />
                    </div>
                    <div>
                      <p className="text-sm font-medium text-slate-800">
                        {sale.customers?.name || sale.customer_name_raw || "Walk-in Customer"}
                      </p>
                      <p className="text-xs text-slate-400">
                        {new Date(sale.sale_date).toLocaleDateString("en-GB", { day: "numeric", month: "short", year: "numeric" })}
                      </p>
                    </div>
                  </div>
                  <div className="text-right">
                    <p className="text-sm font-semibold text-slate-900">${Number(sale.total_amount).toFixed(2)}</p>
                    <span className={`inline-block text-[10px] font-medium px-2 py-0.5 rounded-full mt-0.5 ${
                      sale.payment_status === 'paid'
                        ? 'bg-emerald-50 text-emerald-700'
                        : sale.payment_status === 'credit'
                        ? 'bg-amber-50 text-amber-700'
                        : 'bg-slate-100 text-slate-600'
                    }`}>
                      {sale.payment_status}
                    </span>
                  </div>
                </div>
              ))
            )}
          </div>
        </div>

        {/* Low Stock */}
        <div className="lg:col-span-3 bg-white rounded-2xl border border-slate-200/80 shadow-sm overflow-hidden">
          <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100">
            <div>
              <h3 className="font-semibold text-slate-900">Low Stock Alert</h3>
              <p className="text-xs text-slate-500 mt-0.5">Alaabta dhammaanaysa</p>
            </div>
            <a href="/products" className="text-xs font-medium text-blue-600 hover:text-blue-800 transition-colors flex items-center gap-1">
              View all <ArrowUpRight className="h-3 w-3" />
            </a>
          </div>
          <div className="divide-y divide-slate-100">
            {!lowStockItems || lowStockItems.length === 0 ? (
              <div className="px-6 py-10 text-center">
                <Package className="h-8 w-8 text-slate-300 mx-auto mb-2" />
                <p className="text-sm text-slate-400">Alaab dhammaanaysa ma jirto</p>
              </div>
            ) : (
              lowStockItems.map((item, i) => (
                <div key={i} className="flex items-center justify-between px-6 py-3.5 table-row-hover">
                  <div className="flex items-center gap-3">
                    <div className="w-8 h-8 rounded-full bg-amber-50 flex items-center justify-center shrink-0">
                      <AlertTriangle className="h-3.5 w-3.5 text-amber-500" />
                    </div>
                    <p className="text-sm font-medium text-slate-800 truncate max-w-[160px]">{item.name}</p>
                  </div>
                  <div className="text-right shrink-0">
                    <span className={`text-xs font-bold px-2.5 py-1 rounded-full ${
                      item.quantity_on_hand === 0
                        ? 'bg-rose-50 text-rose-700'
                        : 'bg-amber-50 text-amber-700'
                    }`}>
                      {item.quantity_on_hand === 0 ? "Out" : `${item.quantity_on_hand} left`}
                    </span>
                  </div>
                </div>
              ))
            )}
          </div>
        </div>
      </div>
    </div>
  )
}
