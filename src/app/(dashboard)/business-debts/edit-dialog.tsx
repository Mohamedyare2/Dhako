"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { Edit2 } from "lucide-react";
import { updateBusinessDebt } from "./actions";

interface BusinessDebt {
  id: string;
  supplier_name_raw: string;
  amount_owed: number;
  amount_paid: number;
  description: string;
  due_date?: string;
}

export function EditBusinessDebtDialog({ debt }: { debt: BusinessDebt }) {
  const [open, setOpen] = useState(false);
  const [loading, setLoading] = useState(false);
  const router = useRouter();

  const handleSubmit = async (formData: FormData) => {
    setLoading(true);
    try {
      await updateBusinessDebt(debt.id, formData);
      setOpen(false);
      router.refresh();
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    } catch (err: any) {
      alert(err.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        <Button variant="outline" size="sm" className="rounded-lg border-slate-200 text-slate-600 hover:bg-slate-50 h-7 px-2">
          <Edit2 className="h-3.5 w-3.5 mr-1.5" />
          Edit
        </Button>
      </DialogTrigger>
      <DialogContent className="rounded-2xl border border-slate-200 shadow-2xl">
        <DialogHeader>
          <DialogTitle className="text-slate-900">Bedel Xogta Deynta Meheradda</DialogTitle>
        </DialogHeader>
        <form action={handleSubmit} className="space-y-4 pt-2">
          <div className="grid gap-1.5">
            <Label htmlFor="supplier_name" className="text-sm font-medium text-slate-700">Magaca Qofka/Shirkadda</Label>
            <Input id="supplier_name" name="supplier_name" defaultValue={debt.supplier_name_raw} required className="h-10 border-slate-200 rounded-xl" />
          </div>
          
          <div className="grid grid-cols-2 gap-4">
            <div className="grid gap-1.5">
              <Label htmlFor="amount_owed" className="text-sm font-medium text-slate-700">Deynta ($)</Label>
              <Input type="number" step="0.01" id="amount_owed" name="amount_owed" defaultValue={debt.amount_owed} required className="h-10 border-slate-200 rounded-xl" />
            </div>
            <div className="grid gap-1.5">
              <Label htmlFor="amount_paid" className="text-sm font-medium text-slate-700">La Bixiyay ($)</Label>
              <Input type="number" step="0.01" id="amount_paid" name="amount_paid" defaultValue={debt.amount_paid} required className="h-10 border-slate-200 rounded-xl" />
            </div>
          </div>

          <div className="grid gap-1.5">
            <Label htmlFor="due_date" className="text-sm font-medium text-slate-700">Goormaa La Bixinayaa?</Label>
            <Input type="date" id="due_date" name="due_date" defaultValue={debt.due_date ? debt.due_date.split('T')[0] : ''} className="h-10 border-slate-200 rounded-xl" />
          </div>

          <div className="grid gap-1.5">
            <Label htmlFor="description" className="text-sm font-medium text-slate-700">Faahfaahin</Label>
            <Input id="description" name="description" defaultValue={debt.description} className="h-10 border-slate-200 rounded-xl" />
          </div>

          <Button type="submit" className="w-full bg-slate-900 text-white rounded-xl h-10 font-medium" disabled={loading}>
            {loading ? "Wuu kaydinayaa..." : "Update (Cusbooneysii)"}
          </Button>
        </form>
      </DialogContent>
    </Dialog>
  );
}
