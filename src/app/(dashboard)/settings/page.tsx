"use client";

import { useState, useEffect } from "react";
import { createClient } from "@/lib/supabase/client";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { resetStaffPassword } from "./actions";
import { Lock, Shield, CheckCircle, AlertCircle, KeyRound } from "lucide-react";

export default function SettingsPage() {
  const supabase = createClient();
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState("");

  const [isAdmin, setIsAdmin] = useState(false);
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const [staffList, setStaffList] = useState<any[]>([]);
  const [selectedStaff, setSelectedStaff] = useState("");
  const [staffPassword, setStaffPassword] = useState("");
  const [staffMessage, setStaffMessage] = useState("");
  const [staffLoading, setStaffLoading] = useState(false);

  useEffect(() => {
    async function loadProfile() {
      const { data: { user } } = await supabase.auth.getUser();
      if (user) {
        const { data: profile } = await supabase.from("profiles").select("role").eq("id", user.id).single();
        if (profile?.role === 'admin') {
          setIsAdmin(true);
          const { data: users } = await supabase.from("profiles").select("*").neq("id", user.id);
          if (users) setStaffList(users);
        }
      }
    }
    loadProfile();
  }, [supabase]);

  const handleUpdatePassword = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setMessage("");

    const { error } = await supabase.auth.updateUser({ password: password });

    if (error) {
      setMessage("error:" + error.message);
    } else {
      setMessage("success:Password-kaaga si guul leh ayaa loo bedelay!");
      setPassword("");
    }
    setLoading(false);
  };

  const handleResetStaffPassword = async (e: React.FormEvent) => {
    e.preventDefault();
    setStaffLoading(true);
    setStaffMessage("");

    if (!selectedStaff) {
      setStaffMessage("error:Fadlan dooro qofka shaqaalaha ah.");
      setStaffLoading(false);
      return;
    }

    try {
      await resetStaffPassword(selectedStaff, staffPassword);
      setStaffMessage("success:Password-ka shaqaalaha si guul leh ayaa loo bedelay!");
      setStaffPassword("");
      setSelectedStaff("");
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    } catch (err: any) {
      setStaffMessage("error:" + err.message);
    }
    
    setStaffLoading(false);
  };

  const MessageAlert = ({ msg }: { msg: string }) => {
    const isError = msg.startsWith("error:")
    const text = msg.replace(/^(error|success):/, "")
    return (
      <div className={`flex items-center gap-2 p-3 rounded-xl text-sm ${
        isError ? 'bg-rose-50 text-rose-700 border border-rose-200' : 'bg-emerald-50 text-emerald-700 border border-emerald-200'
      }`}>
        {isError ? <AlertCircle className="h-4 w-4 shrink-0" /> : <CheckCircle className="h-4 w-4 shrink-0" />}
        {text}
      </div>
    )
  }

  return (
    <div className="max-w-2xl mx-auto space-y-6 fade-in">
      <div>
        <h2 className="text-2xl font-bold tracking-tight text-slate-900">Settings</h2>
        <p className="text-slate-500 text-sm mt-0.5">Maamul akoonkaaga (Manage your account)</p>
      </div>

      {/* Change own password */}
      <div className="bg-white rounded-2xl border border-slate-200/80 shadow-sm overflow-hidden">
        <div className="flex items-center gap-3 px-6 py-4 border-b border-slate-100">
          <div className="w-9 h-9 rounded-xl bg-slate-100 flex items-center justify-center text-slate-600">
            <Lock className="h-4.5 w-4.5" />
          </div>
          <div>
            <h3 className="font-semibold text-slate-900">Bedel Password-kaaga</h3>
            <p className="text-xs text-slate-500">Halkan waxaad kaga bedelan kartaa password-ka aad adigu leedahay.</p>
          </div>
        </div>
        <div className="p-6">
          <form onSubmit={handleUpdatePassword} className="space-y-4">
            <div className="grid gap-1.5">
              <Label htmlFor="password" className="text-sm font-medium text-slate-700">Password Cusub (New Password)</Label>
              <div className="relative">
                <KeyRound className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
                <Input 
                  id="password" 
                  type="password" 
                  required 
                  value={password} 
                  onChange={(e) => setPassword(e.target.value)} 
                  placeholder="••••••••"
                  className="pl-10 h-10 border-slate-200 rounded-xl focus:border-slate-900 focus:ring-0"
                />
              </div>
            </div>
            
            {message && <MessageAlert msg={message} />}

            <Button 
              type="submit" 
              className="bg-slate-900 hover:bg-slate-800 rounded-xl h-10 font-medium text-white shadow-sm" 
              disabled={loading}
            >
              {loading ? (
                <span className="flex items-center gap-2">
                  <span className="h-3.5 w-3.5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                  Wuu bedelayaa...
                </span>
              ) : "Bedel Password-ka"}
            </Button>
          </form>
        </div>
      </div>

      {/* Admin: reset staff password */}
      {isAdmin && (
        <div className="bg-white rounded-2xl border border-amber-200 shadow-sm overflow-hidden">
          <div className="flex items-center gap-3 px-6 py-4 border-b border-amber-100 bg-amber-50/60">
            <div className="w-9 h-9 rounded-xl bg-amber-100 flex items-center justify-center text-amber-700">
              <Shield className="h-4.5 w-4.5" />
            </div>
            <div>
              <h3 className="font-semibold text-amber-900">Bedel Password-ka Shaqaalaha</h3>
              <p className="text-xs text-amber-700">Admin Only — Halkan waxaad uga bedeli kartaa password-ka qof kasta oo shaqaale ah.</p>
            </div>
          </div>
          <div className="p-6">
            <form onSubmit={handleResetStaffPassword} className="space-y-4">
              <div className="grid gap-1.5">
                <Label htmlFor="staff" className="text-sm font-medium text-slate-700">Dooro Shaqaalaha (Select Staff)</Label>
                <select 
                  id="staff" 
                  className="flex h-10 w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm focus:outline-none focus:border-slate-900 text-slate-900"
                  value={selectedStaff}
                  onChange={(e) => setSelectedStaff(e.target.value)}
                  required
                >
                  <option value="" disabled>-- Dooro qof --</option>
                  {staffList.map(s => (
                    <option key={s.id} value={s.id}>{s.full_name} ({s.role})</option>
                  ))}
                </select>
              </div>

              <div className="grid gap-1.5">
                <Label htmlFor="staff_password" className="text-sm font-medium text-slate-700">Password-kooda Cusub (New Password)</Label>
                <div className="relative">
                  <KeyRound className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
                  <Input 
                    id="staff_password" 
                    type="password" 
                    required 
                    value={staffPassword} 
                    onChange={(e) => setStaffPassword(e.target.value)} 
                    placeholder="••••••••"
                    className="pl-10 h-10 border-slate-200 rounded-xl focus:border-slate-900 focus:ring-0"
                  />
                </div>
              </div>

              {staffMessage && <MessageAlert msg={staffMessage} />}

              <Button 
                type="submit" 
                className="bg-amber-600 hover:bg-amber-700 text-white rounded-xl h-10 font-medium shadow-sm" 
                disabled={staffLoading}
              >
                {staffLoading ? (
                  <span className="flex items-center gap-2">
                    <span className="h-3.5 w-3.5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                    Wuu bedelayaa...
                  </span>
                ) : "U Bedel Password-ka"}
              </Button>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
