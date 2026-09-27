"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { createBusinessDebt } from "../actions";

export default function AddBusinessDebtPage() {
  const router = useRouter();
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setLoading(true);

    try {
      const formData = new FormData(e.currentTarget);
      await createBusinessDebt(formData);
      router.push("/business-debts");
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    } catch (err: any) {
      alert("Cillad: " + err.message);
      setLoading(false);
    }
  };

  return (
    <div className="max-w-2xl mx-auto space-y-6 fade-in">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-2xl font-bold tracking-tight text-slate-900">Ku Dar Deyn Cusub</h2>
          <p className="text-slate-500 text-sm mt-0.5">Diiwaan geli deyn cusub oo meheradda ku saabsan</p>
        </div>
        <Button variant="outline" type="button" onClick={() => router.back()} className="rounded-xl border-slate-200 text-slate-600 hover:bg-slate-50">
          Ka Noqo
        </Button>
      </div>

      <div className="bg-white rounded-2xl border border-slate-200/80 shadow-sm overflow-hidden">
        <div className="px-6 py-4 border-b border-slate-100">
          <h3 className="font-semibold text-slate-900">Xogta Deynta (Debt Details)</h3>
        </div>
        <div className="p-6">
          <form onSubmit={handleSubmit} className="space-y-4">
            <div className="grid gap-1.5">
              <Label htmlFor="supplier_name" className="text-sm font-medium text-slate-700">Magaca Qofka/Shirkadda Deynta Leh</Label>
              <Input 
                id="supplier_name" 
                name="supplier_name" 
                required 
                placeholder="Tusaale: Shirkadda Dahabshiil ama Axmed"
                className="h-10 border-slate-200 rounded-xl focus:border-slate-900 focus:ring-0"
              />
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div className="grid gap-1.5">
                <Label htmlFor="amount_owed" className="text-sm font-medium text-slate-700">Intee Luguugu leeyahay? ($)</Label>
                <Input 
                  type="number" 
                  step="0.01" 
                  id="amount_owed" 
                  name="amount_owed" 
                  required 
                  placeholder="0.00"
                  className="h-10 border-slate-200 rounded-xl focus:border-slate-900 focus:ring-0"
                />
              </div>
              <div className="grid gap-1.5">
                <Label htmlFor="due_date" className="text-sm font-medium text-slate-700">Goormaa La Bixinayaa? (Ikhtiyaari)</Label>
                <Input 
                  type="date" 
                  id="due_date" 
                  name="due_date" 
                  className="h-10 border-slate-200 rounded-xl focus:border-slate-900 focus:ring-0"
                />
              </div>
            </div>

            <div className="grid gap-1.5">
              <Label htmlFor="description" className="text-sm font-medium text-slate-700">Faahfaahin (Maxay ahayd alaabtu?)</Label>
              <Input 
                id="description" 
                name="description" 
                placeholder="Tusaale: 20 kartoon oo Saliid ah"
                className="h-10 border-slate-200 rounded-xl focus:border-slate-900 focus:ring-0"
              />
            </div>

            <div className="pt-2 flex gap-3">
              <Button type="button" variant="outline" onClick={() => router.back()} className="flex-1 rounded-xl border-slate-200 h-10">
                Cancel
              </Button>
              <Button type="submit" className="flex-1 bg-slate-900 hover:bg-slate-800 text-white rounded-xl h-10 font-medium shadow-sm" disabled={loading}>
                {loading ? (
                  <span className="flex items-center gap-2">
                    <span className="h-3.5 w-3.5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                    Wuu xareynayaa...
                  </span>
                ) : "Save (Kaydi)"}
              </Button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
}
