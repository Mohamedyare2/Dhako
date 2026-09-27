"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { createCustomerDebt } from "../actions";

export default function AddCustomerDebtPage() {
  const router = useRouter();
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setLoading(true);

    try {
      const formData = new FormData(e.currentTarget);
      await createCustomerDebt(formData);
      router.push("/credit");
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    } catch (err: any) {
      alert("Cillad: " + err.message);
      setLoading(false);
    }
  };

  return (
    <div className="max-w-2xl mx-auto space-y-6">
      <div className="flex items-center justify-between">
        <h2 className="text-2xl font-bold tracking-tight">Ku Dar Deyn Cusub</h2>
        <Button variant="outline" type="button" onClick={() => router.back()}>Ka Noqo (Cancel)</Button>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Xogta Deynta Macmiilka</CardTitle>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleSubmit} className="space-y-4">
            <div className="grid gap-2">
              <Label htmlFor="customer_name">Magaca Macmiilka (Customer Name)</Label>
              <Input 
                id="customer_name" 
                name="customer_name" 
                required 
                placeholder="Tusaale: Jaamac Daa'uud"
              />
            </div>

            <div className="grid gap-2">
              <Label htmlFor="amount_owed">Lacagta Deynta Ah ($)</Label>
              <Input 
                type="number" 
                step="0.01" 
                id="amount_owed" 
                name="amount_owed" 
                required 
                placeholder="0.00"
              />
            </div>

            <div className="grid gap-2">
              <Label htmlFor="description">Faahfaahin (Maxay ahayd alaabtu?)</Label>
              <Input 
                id="description" 
                name="description" 
                placeholder="Tusaale: 2 Taayir iyo Saliid"
              />
            </div>

            <div className="pt-4 flex gap-2">
              <Button type="button" variant="outline" onClick={() => router.back()} className="w-full">
                Cancel
              </Button>
              <Button type="submit" className="w-full bg-slate-900 hover:bg-slate-800" disabled={loading}>
                {loading ? "Wuu xareynayaa..." : "Save (Kaydi)"}
              </Button>
            </div>
          </form>
        </CardContent>
      </Card>
    </div>
  );
}
