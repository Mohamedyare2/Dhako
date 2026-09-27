"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent } from "@/components/ui/card";

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export default function EditProductForm({ product }: { product: any }) {
  const router = useRouter();
  const supabase = createClient();
  const [loading, setLoading] = useState(false);

  const [formData, setFormData] = useState({
    name: product.name || "",
    part_code: product.part_code || "",
    vehicle_model: product.vehicle_model || "",
    cost_price: product.cost_price || "0",
    selling_price: product.selling_price || "0",
    quantity_on_hand: product.quantity_on_hand || "0",
    min_stock_level: product.min_stock_level || "5",
  });

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    const { error } = await supabase.from("products").update({
      name: formData.name,
      part_code: formData.part_code,
      vehicle_model: formData.vehicle_model,
      cost_price: parseFloat(String(formData.cost_price)),
      selling_price: parseFloat(String(formData.selling_price)),
      quantity_on_hand: parseInt(String(formData.quantity_on_hand)),
      min_stock_level: parseInt(String(formData.min_stock_level)),
    }).eq("id", product.id);

    if (!error) {
      router.push("/products");
      router.refresh();
    } else {
      alert("Error updating product: " + error.message);
      setLoading(false);
    }
  };

  return (
    <Card>
      <CardContent className="pt-6">
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="grid gap-2">
            <Label htmlFor="name">Product Name (Magaca)</Label>
            <Input id="name" name="name" required value={formData.name} onChange={handleChange} />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div className="grid gap-2">
              <Label htmlFor="part_code">Part Code (Koodhka)</Label>
              <Input id="part_code" name="part_code" value={formData.part_code} onChange={handleChange} />
            </div>
            <div className="grid gap-2">
              <Label htmlFor="vehicle_model">Vehicle Model</Label>
              <Input id="vehicle_model" name="vehicle_model" value={formData.vehicle_model} onChange={handleChange} />
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div className="grid gap-2">
              <Label htmlFor="cost_price">Cost Price ($)</Label>
              <Input type="number" step="0.01" id="cost_price" name="cost_price" required value={formData.cost_price} onChange={handleChange} />
            </div>
            <div className="grid gap-2">
              <Label htmlFor="selling_price">Unit Price ($)</Label>
              <Input type="number" step="0.01" id="selling_price" name="selling_price" required value={formData.selling_price} onChange={handleChange} />
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div className="grid gap-2">
              <Label htmlFor="quantity_on_hand">Stock (Tirada Hadda)</Label>
              <Input type="number" id="quantity_on_hand" name="quantity_on_hand" required value={formData.quantity_on_hand} onChange={handleChange} />
            </div>
            <div className="grid gap-2">
              <Label htmlFor="min_stock_level">Min Stock Alert</Label>
              <Input type="number" id="min_stock_level" name="min_stock_level" required value={formData.min_stock_level} onChange={handleChange} />
            </div>
          </div>

          <div className="pt-4 flex gap-2">
            <Button type="button" variant="outline" onClick={() => router.back()} className="w-full">
              Cancel
            </Button>
            <Button type="submit" className="w-full bg-slate-900" disabled={loading}>
              {loading ? "Wuu xaroodayaa..." : "Save Changes"}
            </Button>
          </div>
        </form>
      </CardContent>
    </Card>
  );
}
