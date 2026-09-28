"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { createProduct } from "../actions";

export default function AddProductPage() {
  const router = useRouter();
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setLoading(true);

    try {
      const formData = new FormData(e.currentTarget);
      await createProduct(formData);
      router.push("/products");
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    } catch (err: any) {
      alert("Cillad: " + err.message);
      setLoading(false);
    }
  };

  return (
    <div className="max-w-2xl mx-auto space-y-6">
      <div className="flex items-center justify-between">
        <h2 className="text-2xl font-bold tracking-tight">Add New Product</h2>
        <Button type="button" variant="outline" onClick={() => router.back()}>Cancel</Button>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Product Details</CardTitle>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleSubmit} className="space-y-4">
            <div className="grid gap-2">
              <Label htmlFor="name">Product Name (Magaca)</Label>
              <Input id="name" name="name" required />
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div className="grid gap-2">
                <Label htmlFor="part_code">Part Code (Koodhka)</Label>
                <Input id="part_code" name="part_code" />
              </div>
              <div className="grid gap-2">
                <Label htmlFor="vehicle_model">Vehicle Model (Nooca Gaadhiga)</Label>
                <Input id="vehicle_model" name="vehicle_model" />
              </div>
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div className="grid gap-2">
                <Label htmlFor="cost_price">Cost Price ($)</Label>
                <Input type="number" step="0.01" id="cost_price" name="cost_price" required defaultValue="0" />
              </div>
              <div className="grid gap-2">
                <Label htmlFor="selling_price">Selling Price ($)</Label>
                <Input type="number" step="0.01" id="selling_price" name="selling_price" required defaultValue="0" />
              </div>
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div className="grid gap-2">
                <Label htmlFor="quantity_on_hand">Initial Stock (Tirada)</Label>
                <Input type="number" id="quantity_on_hand" name="quantity_on_hand" required defaultValue="1" />
              </div>
              <div className="grid gap-2">
                <Label htmlFor="min_stock_level">Min Stock Alert Level</Label>
                <Input type="number" id="min_stock_level" name="min_stock_level" required defaultValue="5" />
              </div>
            </div>

            <div className="pt-4">
              <Button type="submit" className="w-full bg-slate-900 text-white hover:bg-slate-800" disabled={loading}>
                {loading ? "Saving..." : "Save Product"}
              </Button>
            </div>
          </form>
        </CardContent>
      </Card>
    </div>
  );
}
