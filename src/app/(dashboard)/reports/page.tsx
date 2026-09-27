import { createClient } from "@/lib/supabase/server"
import { DollarSign, TrendingUp, Lock } from "lucide-react"

export default async function ReportsPage({
  searchParams,
}: {
  searchParams: { filter?: string, custom_date?: string }
}) {
  const supabase = createClient()
  
  // Get current user role
  const { data: { user } } = await supabase.auth.getUser()
  let isAdmin = false
  if (user) {
    const { data: profile } = await supabase.from("profiles").select("role").eq("id", user.id).single()
    isAdmin = profile?.role === 'admin'
  }

  const filter = searchParams.filter || "maanta" // maanta, shalay, bisha, sanadka, all, custom
  const customDate = searchParams.custom_date // YYYY-MM-DD

  // Calculate the date boundary
  const dateObj = new Date();
  let startDateStr = "1970-01-01";
  let endDateStr = "2099-12-31"; // For specific day filtering
  
  if (filter === "custom" && customDate) {
    const d = new Date(customDate);
    d.setHours(0, 0, 0, 0);
    startDateStr = d.toISOString();
    const ed = new Date(customDate);
    ed.setHours(23, 59, 59, 999);
    endDateStr = ed.toISOString();
  } else if (filter === "maanta") {
    dateObj.setHours(0, 0, 0, 0);
    startDateStr = dateObj.toISOString();
  } else if (filter === "shalay") {
    dateObj.setDate(dateObj.getDate() - 1);
    dateObj.setHours(0, 0, 0, 0);
    startDateStr = dateObj.toISOString();
    const ed = new Date(dateObj);
    ed.setHours(23, 59, 59, 999);
    endDateStr = ed.toISOString();
  } else if (filter === "bisha") {
    dateObj.setDate(1);
    dateObj.setHours(0, 0, 0, 0);
    startDateStr = dateObj.toISOString();
  } else if (filter === "sanadka") {
    dateObj.setMonth(0, 1);
    dateObj.setHours(0, 0, 0, 0);
    startDateStr = dateObj.toISOString();
  }

  // Get sales with items
  let query = supabase
    .from("sales")
    .select("total_amount, sale_date, sale_items(product_id, quantity, unit_price)")

  if (filter !== "all") {
    query = query.gte("sale_date", startDateStr);
    if (filter === "shalay" || filter === "custom") {
      query = query.lte("sale_date", endDateStr);
    }
  }

  const { data: sales, error } = await query

  // We need to fetch product costs to calculate real profit
  const { data: products } = await supabase.from("products").select("id, cost_price")
  
  const productCosts = new Map()
  products?.forEach(p => productCosts.set(p.id, Number(p.cost_price)))

  let totalRevenue = 0
  let totalCost = 0

  sales?.forEach(sale => {
    totalRevenue += Number(sale.total_amount)
    
    // Calculate cost based on items
    sale.sale_items?.forEach(item => {
      const cost = productCosts.get(item.product_id) || 0
      totalCost += (cost * item.quantity)
    })
  })

  const totalProfit = totalRevenue - totalCost

  const filterButtons = [
    { label: "Maanta", val: "maanta" },
    { label: "Shalay", val: "shalay" },
    { label: "Bishan", val: "bisha" },
    { label: "Sanadkan", val: "sanadka" },
    { label: "Dhan (All)", val: "all" },
  ]

  return (
    <div className="space-y-8 fade-in">
      <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-4 border-b border-slate-200/80 pb-5">
        <div>
          <h2 className="text-2xl font-bold tracking-tight text-slate-900">Warbixinta (Reports)</h2>
          <p className="text-slate-500 text-sm mt-0.5">Eeg iibka iyo faa&apos;iidada meheradda</p>
        </div>
        
        <div className="flex flex-wrap items-center gap-2">
          {filterButtons.map((btn) => (
            <a
              key={btn.val}
              href={`/reports?filter=${btn.val}`}
              className={`px-3.5 py-1.5 rounded-xl text-xs font-semibold transition-all ${
                filter === btn.val
                  ? "bg-slate-900 text-white shadow-sm"
                  : "bg-white border border-slate-200 text-slate-600 hover:bg-slate-50"
              }`}
            >
              {btn.label}
            </a>
          ))}
          
          <form className="flex items-center gap-2 ml-1" method="GET" action="/reports">
            <input type="hidden" name="filter" value="custom" />
            <input 
              type="date" 
              name="custom_date" 
              defaultValue={customDate || ""}
              required
              className="border border-slate-200 rounded-xl px-3 py-1 text-xs h-8 bg-white focus:outline-none focus:border-slate-900"
            />
            <button type="submit" className="bg-slate-900 text-white px-3 py-1 rounded-xl text-xs font-medium h-8 hover:bg-slate-800 transition-colors">
              Filter
            </button>
          </form>
        </div>
      </div>

      {error ? (
        <div className="p-4 bg-rose-50 border border-rose-200 text-rose-700 rounded-2xl text-sm">
          ⚠️ Error loading report: {error.message}
        </div>
      ) : (
        <div className="grid gap-6 md:grid-cols-3">
          {/* Revenue */}
          <div className="bg-white rounded-2xl border border-slate-200/80 p-6 shadow-sm card-hover">
            <div className="flex items-center justify-between mb-4">
              <span className="text-xs font-semibold uppercase tracking-wider text-slate-400">Total Revenue</span>
              <div className="w-9 h-9 rounded-xl bg-blue-50 flex items-center justify-center text-blue-600">
                <DollarSign className="h-5 w-5" />
              </div>
            </div>
            <div className="text-3xl font-extrabold text-slate-900">${totalRevenue.toFixed(2)}</div>
            <p className="text-xs text-slate-500 mt-1">Wadarta iibka muddada la doortay</p>
          </div>
          
          {isAdmin ? (
            <>
              {/* Cost */}
              <div className="bg-white rounded-2xl border border-slate-200/80 p-6 shadow-sm card-hover">
                <div className="flex items-center justify-between mb-4">
                  <span className="text-xs font-semibold uppercase tracking-wider text-slate-400">Total Cost</span>
                  <div className="w-9 h-9 rounded-xl bg-rose-50 flex items-center justify-center text-rose-600">
                    <DollarSign className="h-5 w-5" />
                  </div>
                </div>
                <div className="text-3xl font-extrabold text-rose-600">${totalCost.toFixed(2)}</div>
                <p className="text-xs text-slate-500 mt-1">Qiimaha rasmiga ah ee alaabta</p>
              </div>

              {/* Profit */}
              <div className="sidebar-gradient text-white rounded-2xl p-6 shadow-lg shadow-slate-900/10 card-hover border border-white/10 relative overflow-hidden">
                <div className="absolute top-0 right-0 w-32 h-32 bg-blue-500/10 rounded-full translate-x-10 -translate-y-10 pointer-events-none" />
                <div className="flex items-center justify-between mb-4 relative z-10">
                  <span className="text-xs font-semibold uppercase tracking-wider text-blue-300">Net Profit</span>
                  <div className="w-9 h-9 rounded-xl bg-emerald-500/20 flex items-center justify-center text-emerald-400 border border-emerald-500/30">
                    <TrendingUp className="h-5 w-5" />
                  </div>
                </div>
                <div className="text-3xl font-extrabold text-emerald-400 relative z-10">${totalProfit.toFixed(2)}</div>
                <p className="text-xs text-slate-400 mt-1 relative z-10">Faa&apos;iidada net-ka ah</p>
              </div>
            </>
          ) : (
            <div className="md:col-span-2 bg-slate-100/70 border border-slate-200 rounded-2xl p-6 flex flex-col items-center justify-center text-center">
              <Lock className="h-6 w-6 text-slate-400 mb-2" />
              <p className="text-sm font-medium text-slate-600">Admin Privileges Required</p>
              <p className="text-xs text-slate-400 mt-1">Xogta faa&apos;iidada iyo qiimaha iibka waxaa arki kara maamulaha (Admin) oo kaliya.</p>
            </div>
          )}
        </div>
      )}
    </div>
  )
}
