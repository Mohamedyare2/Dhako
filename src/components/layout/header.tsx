"use client";

import { Menu, LogOut, User, Settings } from "lucide-react";
import { Button } from "@/components/ui/button";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { createClient } from "@/lib/supabase/client";
import { useRouter, usePathname } from "next/navigation";
import Link from "next/link";

const pageTitles: Record<string, { title: string; desc: string }> = {
  "/dashboard": { title: "Dashboard", desc: "Nidaamka guud ee meheradda" },
  "/products": { title: "Products", desc: "Maamul alaabta bakhaarkaaga" },
  "/sales": { title: "Sales", desc: "Waxqabadka iibka" },
  "/customers": { title: "Customers", desc: "Macaamiisha meheradda" },
  "/credit": { title: "Deynta Macaamiisha", desc: "Deymaha macaamiisha lagu leeyahay" },
  "/business-debts": { title: "Deynta Meheradda", desc: "Accounts Payable" },
  "/categories": { title: "Categories", desc: "Noocyada alaabta" },
  "/inventory": { title: "Inventory", desc: "Tirada alaabta" },
  "/reports": { title: "Warbixinta", desc: "Faahfaahinta iibka iyo faa'iidada" },
  "/settings": { title: "Settings", desc: "Qaabaynta nidaamka" },
};

export function Header({ setMobileMenuOpen }: { setMobileMenuOpen: (open: boolean) => void }) {
  const router = useRouter();
  const pathname = usePathname();
  const supabase = createClient();

  const handleLogout = async () => {
    await supabase.auth.signOut();
    router.push("/login");
  };

  // Get the title for the current page
  const matchedKey = Object.keys(pageTitles).find(k => pathname === k || pathname.startsWith(k + "/"));
  const pageInfo = matchedKey ? pageTitles[matchedKey] : { title: "Dhako", desc: "" };

  return (
    <header className="sticky top-0 z-30 flex h-16 items-center gap-4 border-b border-slate-200 bg-white/90 backdrop-blur-sm px-4 md:px-6 shadow-sm">
      {/* Mobile menu button */}
      <Button
        variant="ghost"
        size="icon"
        className="md:hidden text-slate-600 hover:text-slate-900 hover:bg-slate-100"
        onClick={() => setMobileMenuOpen(true)}
      >
        <Menu className="h-5 w-5" />
        <span className="sr-only">Toggle menu</span>
      </Button>

      {/* Page title (desktop) */}
      <div className="hidden md:flex flex-col">
        <h1 className="text-base font-semibold text-slate-900 leading-tight">{pageInfo.title}</h1>
        {pageInfo.desc && (
          <p className="text-xs text-slate-500">{pageInfo.desc}</p>
        )}
      </div>

      <div className="flex-1" />

      {/* Right side actions */}
      <div className="flex items-center gap-2">
        {/* Settings shortcut */}
        <Link href="/settings">
          <Button variant="ghost" size="icon" className="text-slate-500 hover:text-slate-900 hover:bg-slate-100 rounded-full">
            <Settings className="h-4.5 w-4.5" />
          </Button>
        </Link>

        {/* User menu */}
        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <Button
              variant="ghost"
              className="flex items-center gap-2 h-9 px-2.5 rounded-full hover:bg-slate-100 text-slate-700 border border-slate-200"
            >
              <div className="w-6 h-6 rounded-full bg-slate-800 flex items-center justify-center">
                <User className="h-3.5 w-3.5 text-white" />
              </div>
              <span className="text-sm font-medium hidden sm:block">Account</span>
            </Button>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end" className="w-52 shadow-xl border-slate-200">
            <DropdownMenuLabel className="text-xs text-slate-500 font-normal">Logged in as</DropdownMenuLabel>
            <DropdownMenuLabel className="pt-0 text-slate-900">Admin</DropdownMenuLabel>
            <DropdownMenuSeparator />
            <DropdownMenuItem asChild>
              <Link href="/settings" className="cursor-pointer">
                <Settings className="mr-2 h-4 w-4 text-slate-500" />
                Settings
              </Link>
            </DropdownMenuItem>
            <DropdownMenuSeparator />
            <DropdownMenuItem
              onClick={handleLogout}
              className="text-red-600 focus:text-red-600 focus:bg-red-50 cursor-pointer"
            >
              <LogOut className="mr-2 h-4 w-4" />
              Sign out
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      </div>
    </header>
  );
}
