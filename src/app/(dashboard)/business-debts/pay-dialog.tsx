"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { payBusinessDebt } from "./actions";

export default function PayDebtDialog({ 
  debtId, 
  supplierName, 
  remainingAmount 
}: { 
  debtId: string, 
  supplierName: string, 
  remainingAmount: number 
}) {
  const [open, setOpen] = useState(false);
  const [loading, setLoading] = useState(false);
  const [amount, setAmount] = useState("");
  const router = useRouter();

  const handlePay = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      await payBusinessDebt(debtId, parseFloat(amount));
      setOpen(false);
      setAmount("");
      router.refresh();
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    } catch (err: any) {
      alert("Cillad: " + err.message);
    }
    setLoading(false);
  };

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        <Button variant="outline" size="sm" className="rounded-lg border-emerald-200 text-emerald-700 hover:bg-emerald-50 hover:border-emerald-300 font-medium text-xs h-7 px-2.5">
          Bixi Lacag
        </Button>
      </DialogTrigger>
      <DialogContent className="rounded-2xl border border-slate-200 shadow-2xl">
        <DialogHeader>
          <DialogTitle className="text-slate-900">Bixi Lacagta Deynta</DialogTitle>
          <DialogDescription className="text-slate-500 text-sm leading-relaxed">
            Qofka/Shirkadda: <span className="font-semibold text-slate-700">{supplierName}</span>
            <br/>
            Haraaga Deynta: <span className="font-bold text-rose-600">${remainingAmount.toFixed(2)}</span>
          </DialogDescription>
        </DialogHeader>
        <form onSubmit={handlePay} className="space-y-4 pt-2">
          <div className="grid gap-1.5">
            <Label htmlFor="amount" className="text-sm font-medium text-slate-700">Imisa ayaad bixinaysaa hadda? ($)</Label>
            <Input 
              id="amount" 
              type="number" 
              step="0.01" 
              max={remainingAmount}
              required 
              value={amount}
              onChange={(e) => setAmount(e.target.value)}
              placeholder="Tusaale: 30.00"
              className="h-10 border-slate-200 rounded-xl focus:border-slate-900 focus:ring-0"
            />
          </div>
          <Button type="submit" className="w-full bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl h-10 font-medium shadow-sm" disabled={loading}>
            {loading ? (
              <span className="flex items-center gap-2">
                <span className="h-3.5 w-3.5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                Wuu xaraynayaa...
              </span>
            ) : "Bixi (Pay)"}
          </Button>
        </form>
      </DialogContent>
    </Dialog>
  );
}
