"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { cn } from "@/lib/utils";
import {
  LayoutDashboard,
  Package,
  ShoppingCart,
  Users,
  CreditCard,
  Settings,
  Archive,
  TrendingUp,
  Landmark,
  ChevronRight,
} from "lucide-react";

const navGroups = [
  {
    label: "Overview",
    items: [
      { href: "/dashboard", icon: LayoutDashboard, label: "Dashboard" },
      { href: "/reports", icon: TrendingUp, label: "Warbixinta" },
    ],
  },
  {
    label: "Alaabta",
    items: [
      { href: "/products", icon: Package, label: "Products" },
      { href: "/inventory", icon: Archive, label: "Inventory" },
      { href: "/categories", icon: Settings, label: "Categories" },
    ],
  },
  {
    label: "Ganacsiga",
    items: [
      { href: "/sales", icon: ShoppingCart, label: "Sales" },
      { href: "/customers", icon: Users, label: "Customers" },
    ],
  },
  {
    label: "Deymaha",
    items: [
      { href: "/credit", icon: CreditCard, label: "Deynta Macaamiisha" },
      { href: "/business-debts", icon: Landmark, label: "Deynta Meheradda" },
    ],
  },
  {
    label: "Nidaamka",
    items: [
      { href: "/settings", icon: Settings, label: "Settings" },
    ],
  },
];

export function Sidebar() {
  const pathname = usePathname();

  return (
    <div className="flex h-full w-64 flex-col sidebar-gradient text-white border-r border-white/5">
      {/* Logo */}
      <div className="flex h-16 items-center px-5 border-b border-white/10 shrink-0">
        <div className="flex items-center gap-2.5">
          <div className="w-8 h-8 rounded-lg bg-blue-500 flex items-center justify-center shadow-lg shadow-blue-500/30">
            <Package className="h-4.5 w-4.5 text-white" strokeWidth={2.5} />
          </div>
          <div>
            <div className="text-[15px] font-bold text-white leading-none tracking-tight">Dhako</div>
            <div className="text-[10px] text-slate-400 mt-0.5 font-medium tracking-wide uppercase">Spare Parts</div>
          </div>
        </div>
      </div>

      {/* Navigation */}
      <div className="flex-1 overflow-y-auto py-4 px-3 space-y-5">
        {navGroups.map((group) => (
          <div key={group.label}>
            <div className="px-3 mb-1.5">
              <span className="text-[10px] font-semibold uppercase tracking-[0.08em] text-slate-500">
                {group.label}
              </span>
            </div>
            <nav className="space-y-0.5">
              {group.items.map((item) => {
                const isActive = pathname === item.href || pathname.startsWith(item.href + "/");
                return (
                  <Link
                    key={item.href}
                    href={item.href}
                    className={cn(
                      "flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-all duration-150 group relative",
                      isActive
                        ? "bg-blue-500/15 text-blue-400 border border-blue-500/20"
                        : "text-slate-400 hover:bg-white/5 hover:text-slate-200"
                    )}
                  >
                    <item.icon
                      className={cn(
                        "h-4 w-4 shrink-0 transition-colors",
                        isActive ? "text-blue-400" : "text-slate-500 group-hover:text-slate-300"
                      )}
                    />
                    <span className="truncate">{item.label}</span>
                    {isActive && (
                      <ChevronRight className="h-3 w-3 ml-auto text-blue-400/60" />
                    )}
                  </Link>
                );
              })}
            </nav>
          </div>
        ))}
      </div>

      {/* Footer */}
      <div className="p-4 border-t border-white/10 shrink-0">
        <div className="flex items-center gap-2.5 px-1">
          <div className="w-7 h-7 rounded-full bg-slate-600 flex items-center justify-center text-xs font-semibold text-slate-300">
            D
          </div>
          <div>
            <div className="text-xs font-medium text-slate-300">Dhako System</div>
            <div className="text-[10px] text-slate-500">© {new Date().getFullYear()}</div>
          </div>
        </div>
      </div>
    </div>
  );
}
