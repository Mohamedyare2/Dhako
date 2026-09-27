"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { Plus, Edit2 } from "lucide-react";
import { createCustomer, updateCustomer } from "./actions";

interface Customer {
  id: string;
  name: string;
  phone: string;
  notes: string;
}

export function AddCustomerDialog() {
  const [open, setOpen] = useState(false);
  const [loading, setLoading] = useState(false);
  const router = useRouter();

  const handleSubmit = async (formData: FormData) => {
    setLoading(true);
    try {
      await createCustomer(formData);
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
        <Button className="bg-slate-900 hover:bg-slate-800 text-white rounded-xl shadow-sm h-10 px-4 font-medium">
          <Plus className="mr-2 h-4 w-4" />
          Ku Dar Macaamiil
        </Button>
      </DialogTrigger>
      <DialogContent className="rounded-2xl border border-slate-200 shadow-2xl">
        <DialogHeader>
          <DialogTitle className="text-slate-900">Ku Dar Macmiil Cusub</DialogTitle>
          <DialogDescription className="text-slate-500 text-sm">
            Geli xogta macmiilka si aad ugu diiwaangeliso nidaamka.
          </DialogDescription>
        </DialogHeader>
        <form action={handleSubmit} className="space-y-4 pt-2">
          <div className="grid gap-1.5">
            <Label htmlFor="name" className="text-sm font-medium text-slate-700">Magaca (Name)</Label>
            <Input id="name" name="name" required placeholder="Tusaale: Axmed Jaamac" className="h-10 border-slate-200 rounded-xl focus:border-slate-900" />
          </div>
          <div className="grid gap-1.5">
            <Label htmlFor="phone" className="text-sm font-medium text-slate-700">Telefoonka (Phone)</Label>
            <Input id="phone" name="phone" placeholder="Tusaale: +252 61XXXXXXX" className="h-10 border-slate-200 rounded-xl focus:border-slate-900" />
          </div>
          <div className="grid gap-1.5">
            <Label htmlFor="notes" className="text-sm font-medium text-slate-700">Faahfaahin (Notes)</Label>
            <Input id="notes" name="notes" placeholder="Tusaale: Waa macmiil joogto ah" className="h-10 border-slate-200 rounded-xl focus:border-slate-900" />
          </div>
          <Button type="submit" className="w-full bg-slate-900 hover:bg-slate-800 text-white rounded-xl h-10 font-medium" disabled={loading}>
            {loading ? "Wuu xareynayaa..." : "Save (Kaydi)"}
          </Button>
        </form>
      </DialogContent>
    </Dialog>
  );
}

export function EditCustomerDialog({ customer }: { customer: Customer }) {
  const [open, setOpen] = useState(false);
  const [loading, setLoading] = useState(false);
  const router = useRouter();

  const handleSubmit = async (formData: FormData) => {
    setLoading(true);
    try {
      await updateCustomer(customer.id, formData);
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
        <Button variant="outline" size="sm" className="rounded-lg border-slate-200 text-slate-600 hover:bg-slate-50 h-8 px-3">
          <Edit2 className="h-3.5 w-3.5 mr-1.5" />
          Edit
        </Button>
      </DialogTrigger>
      <DialogContent className="rounded-2xl border border-slate-200 shadow-2xl">
        <DialogHeader>
          <DialogTitle className="text-slate-900">Bedel Xogta Macmiilka</DialogTitle>
        </DialogHeader>
        <form action={handleSubmit} className="space-y-4 pt-2">
          <div className="grid gap-1.5">
            <Label htmlFor="name" className="text-sm font-medium text-slate-700">Magaca (Name)</Label>
            <Input id="name" name="name" defaultValue={customer.name} required className="h-10 border-slate-200 rounded-xl" />
          </div>
          <div className="grid gap-1.5">
            <Label htmlFor="phone" className="text-sm font-medium text-slate-700">Telefoonka (Phone)</Label>
            <Input id="phone" name="phone" defaultValue={customer.phone} className="h-10 border-slate-200 rounded-xl" />
          </div>
          <div className="grid gap-1.5">
            <Label htmlFor="notes" className="text-sm font-medium text-slate-700">Faahfaahin (Notes)</Label>
            <Input id="notes" name="notes" defaultValue={customer.notes} className="h-10 border-slate-200 rounded-xl" />
          </div>
          <Button type="submit" className="w-full bg-slate-900 text-white rounded-xl h-10 font-medium" disabled={loading}>
            {loading ? "Wuu kaydinayaa..." : "Update (Cusbooneysii)"}
          </Button>
        </form>
      </DialogContent>
    </Dialog>
  );
}
