"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { AlertTriangle, Eye, EyeOff, Lock, Mail, Package } from "lucide-react";

export default function LoginPage() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const router = useRouter();
  const supabase = createClient();

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    setError(null);

    const { error } = await supabase.auth.signInWithPassword({ email, password });

    if (error) {
      setError(error.message);
      setIsLoading(false);
    } else {
      router.push("/dashboard");
    }
  };

  return (
    <div className="min-h-screen w-full flex bg-slate-50">

      {/* ===== LEFT PANEL — Desktop only branding ===== */}
      <div className="hidden lg:flex lg:w-[45%] sidebar-gradient flex-col justify-between p-12 relative overflow-hidden">
        {/* Decorative blobs */}
        <div className="absolute top-0 right-0 w-72 h-72 bg-blue-500/10 rounded-full -translate-y-1/2 translate-x-1/2" />
        <div className="absolute bottom-0 left-0 w-56 h-56 bg-blue-500/8 rounded-full translate-y-1/2 -translate-x-1/2" />
        <div className="absolute top-1/2 right-12 w-32 h-32 bg-white/3 rounded-2xl rotate-12" />

        {/* Logo */}
        <div className="flex items-center gap-3 relative z-10">
          <div className="w-10 h-10 rounded-xl bg-blue-500 flex items-center justify-center shadow-lg shadow-blue-500/30">
            <Package className="h-5 w-5 text-white" strokeWidth={2.5} />
          </div>
          <div>
            <div className="text-lg font-bold text-white">Dhako Spare Parts</div>
            <div className="text-xs text-slate-400 font-medium">Management System</div>
          </div>
        </div>

        {/* Center content */}
        <div className="relative z-10">
          <h2 className="text-4xl font-bold text-white leading-tight mb-4">
            Maamul<br />
            <span className="text-blue-400">Meheradda</span><br />
            si Fudud
          </h2>
          <p className="text-slate-400 text-base leading-relaxed max-w-xs">
            Nidaam casri ah oo loogu talagalay maamulka bakhaarkaaga, iibkaaga, iyo xisaabaadkaaga.
          </p>
          <div className="flex flex-wrap gap-2 mt-8">
            {["Alaabta", "Iibka", "Deymaha", "Warbixinta"].map((f) => (
              <span key={f} className="inline-flex items-center px-3 py-1.5 rounded-full text-xs font-medium bg-white/8 text-slate-300 border border-white/10">
                {f}
              </span>
            ))}
          </div>
        </div>

        {/* Footer */}
        <div className="relative z-10">
          <p className="text-xs text-slate-600">© {new Date().getFullYear()} Dhako System. All rights reserved.</p>
        </div>
      </div>

      {/* ===== RIGHT PANEL — Form (also full screen on mobile) ===== */}
      <div className="flex-1 flex flex-col items-center justify-center p-6 sm:p-10 min-h-screen">
        <div className="w-full max-w-[400px]">

          {/* ===== MOBILE HERO (hidden on desktop) ===== */}
          <div className="lg:hidden flex flex-col items-center text-center mb-10">
            {/* Big Icon */}
            <div className="w-24 h-24 rounded-3xl bg-slate-900 flex items-center justify-center shadow-2xl shadow-slate-900/40 mb-6">
              <Package className="h-12 w-12 text-white" strokeWidth={2} />
            </div>

            {/* Big Title */}
            <h1 className="text-3xl font-extrabold text-slate-900 tracking-tight">
              Dhako
            </h1>
            <h2 className="text-2xl font-extrabold text-blue-600 tracking-tight mb-2">
              Spare Parts
            </h2>
            <p className="text-sm text-slate-500 max-w-xs leading-relaxed">
              Nidaam casri ah oo loogu talagalay maamulka meheradda
            </p>

            {/* Divider */}
            <div className="flex items-center gap-3 w-full mt-8 mb-2">
              <div className="h-px flex-1 bg-slate-200" />
              <span className="text-xs text-slate-400 font-medium">Gal Nidaamka</span>
              <div className="h-px flex-1 bg-slate-200" />
            </div>
          </div>

          {/* ===== Desktop heading (hidden on mobile) ===== */}
          <div className="hidden lg:block mb-8">
            <h1 className="text-2xl font-bold text-slate-900 mb-1">Sign in</h1>
            <p className="text-slate-500 text-sm">Geli xogta kuu gaarka ah si aad gasho nidaamka</p>
          </div>

          {/* ===== LOGIN FORM ===== */}
          <form onSubmit={handleLogin} className="space-y-5">
            {error && (
              <div className="flex items-start gap-3 bg-red-50 border border-red-200 text-red-700 p-3.5 rounded-xl text-sm">
                <AlertTriangle className="h-4 w-4 mt-0.5 shrink-0" />
                <span>{error}</span>
              </div>
            )}

            <div className="space-y-1.5">
              <Label htmlFor="email" className="text-sm font-medium text-slate-700">Email Address</Label>
              <div className="relative">
                <Mail className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
                <Input
                  id="email"
                  type="email"
                  placeholder="admin@dhako.com"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  required
                  className="pl-10 h-12 border-slate-200 bg-white focus:border-slate-900 focus:ring-0 rounded-xl text-slate-900 placeholder:text-slate-400 text-base"
                />
              </div>
            </div>

            <div className="space-y-1.5">
              <Label htmlFor="password" className="text-sm font-medium text-slate-700">Password</Label>
              <div className="relative">
                <Lock className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
                <Input
                  id="password"
                  type={showPassword ? "text" : "password"}
                  placeholder="••••••••"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  required
                  className="pl-10 pr-10 h-12 border-slate-200 bg-white focus:border-slate-900 focus:ring-0 rounded-xl text-slate-900 text-base"
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 transition-colors"
                >
                  {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                </button>
              </div>
            </div>

            <Button
              type="submit"
              className="w-full h-13 bg-slate-900 hover:bg-slate-800 text-white font-bold rounded-xl transition-all duration-200 shadow-lg shadow-slate-900/20 mt-2 text-base py-4"
              disabled={isLoading}
            >
              {isLoading ? (
                <span className="flex items-center gap-2">
                  <span className="h-4 w-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                  Wuu Galayaa...
                </span>
              ) : (
                "Gal Nidaamka →"
              )}
            </Button>
          </form>

          <p className="mt-8 text-center text-xs text-slate-400">
            © {new Date().getFullYear()} Dhako Spare Parts System
          </p>
        </div>
      </div>
    </div>
  );
}
