"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { createClient } from "@/lib/supabase/client";
import { Trash2, Plus, Search, ShoppingCart } from "lucide-react";

interface Product {
  id: string;
  name: string;
  selling_price: number;
  quantity_on_hand: number;
}

interface Customer {
  id: string;
  name: string;
  phone?: string;
}

export default function NewSaleForm({ products, customers }: { products: Product[], customers: Customer[] }) {
  const router = useRouter();
  const supabase = createClient();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  // Cart state
  const [cart, setCart] = useState<{ product: Product, quantity: number, price: number }[]>([]);
  const [selectedProductId, setSelectedProductId] = useState("");
  const [qtyInput, setQtyInput] = useState("1");
  const [priceInput, setPriceInput] = useState("");

  // Sale metadata
  const [isWalkIn, setIsWalkIn] = useState(true);
  const [customerId, setCustomerId] = useState("");
  const [customerNameRaw, setCustomerNameRaw] = useState("");
  const [paymentStatus, setPaymentStatus] = useState("paid"); // paid, partial, credit
  const [amountPaid, setAmountPaid] = useState("");

  // Search filter
  const [search, setSearch] = useState("");

  const filteredProducts = products.filter(p => 
    p.name.toLowerCase().includes(search.toLowerCase()) && p.quantity_on_hand > 0
  );

  const totalAmount = cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);

  const handleAddToCart = () => {
    if (!selectedProductId) return;
    const product = products.find(p => p.id === selectedProductId);
    if (!product) return;

    const q = parseInt(qtyInput) || 1;
    if (q <= 0) return;
    if (q > product.quantity_on_hand) {
      alert(`Kaliya ${product.quantity_on_hand} ayaa kaydka ku jira!`);
      return;
    }

    const price = priceInput ? parseFloat(priceInput) : product.selling_price;

    setCart(prev => {
      const existing = prev.find(item => item.product.id === product.id);
      if (existing) {
        if (existing.quantity + q > product.quantity_on_hand) {
          alert(`Kaliya ${product.quantity_on_hand} ayaa kaydka ku jira!`);
          return prev;
        }
        return prev.map(item => 
          item.product.id === product.id 
            ? { ...item, quantity: item.quantity + q, price: price } 
            : item
        );
      }
      return [...prev, { product, quantity: q, price }];
    });

    // Reset inputs
    setSelectedProductId("");
    setQtyInput("1");
    setPriceInput("");
  };

  const removeFromCart = (productId: string) => {
    setCart(prev => prev.filter(item => item.product.id !== productId));
  };

  const handleProductSelect = (p: Product) => {
    setSelectedProductId(p.id);
    setPriceInput(p.selling_price.toString());
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (cart.length === 0) {
      setError("Fadlan ku dar alaabta la iibinayo (Cart is empty)");
      return;
    }

    if (!isWalkIn && !customerId && !customerNameRaw) {
      setError("Fadlan dooro ama qor magaca macmiilka");
      return;
    }

    setLoading(true);
    setError("");

    try {
      const { data: { user } } = await supabase.auth.getUser();
      
      const paidAmt = paymentStatus === 'paid' ? totalAmount : (paymentStatus === 'credit' ? 0 : parseFloat(amountPaid || "0"));
      const finalCustomerId = !isWalkIn && customerId ? customerId : null;
      const finalCustomerRaw = !isWalkIn && !customerId ? customerNameRaw : null;

      // 1. Create Sale
      const { data: saleData, error: saleError } = await supabase
        .from("sales")
        .insert({
          customer_id: finalCustomerId,
          customer_name_raw: finalCustomerRaw,
          total_amount: totalAmount,
          amount_paid: paidAmt,
          payment_status: paymentStatus,
          created_by: user?.id
        })
        .select()
        .single();

      if (saleError) throw new Error(saleError.message);

      // 2. Create Sale Items & Update Inventory
      const saleItems = cart.map(item => ({
        sale_id: saleData.id,
        product_id: item.product.id,
        product_name_raw: item.product.name,
        quantity: item.quantity,
        unit_price: item.price,
        subtotal: item.quantity * item.price
      }));

      const { error: itemsError } = await supabase.from("sale_items").insert(saleItems);
      if (itemsError) throw new Error(itemsError.message);

      // 3. Update products stock
      for (const item of cart) {
        const { error: updateError } = await supabase.rpc('decrement_product_quantity', {
          p_id: item.product.id,
          p_quantity: item.quantity
        });
        
        // If RPC doesn't exist, fallback to direct update (might have race conditions but works for now)
        if (updateError) {
          await supabase
            .from('products')
            .update({ quantity_on_hand: item.product.quantity_on_hand - item.quantity })
            .eq('id', item.product.id);
        }
      }

      // 4. Create Credit Account if credit or partial
      if (paymentStatus === 'credit' || paymentStatus === 'partial') {
        const { error: creditError } = await supabase.from("credit_accounts").insert({
          customer_id: finalCustomerId,
          customer_name_raw: finalCustomerRaw,
          amount_owed: totalAmount,
          amount_paid: paidAmt,
          status: 'open',
          description: `Deyn iib: ${cart.map(c => c.product.name).join(", ")}`
        });
        if (creditError) throw new Error(creditError.message);
      }

      router.push("/sales");
      router.refresh();
      
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    } catch (err: any) {
      setError(err.message || "Waxaa dhacday cillad");
      setLoading(false);
    }
  };

  return (
    <div className="grid gap-6 lg:grid-cols-12">
      {/* LEFT: PRODUCTS LIST & ADD TO CART */}
      <div className="lg:col-span-7 space-y-4">
        <div className="bg-white rounded-2xl border border-slate-200/80 shadow-sm overflow-hidden p-6">
          <h3 className="font-semibold text-slate-900 mb-4">Alaabta (Products)</h3>
          
          <div className="relative mb-4">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
            <Input 
              type="search" 
              placeholder="Raadi alaab..." 
              value={search}
              onChange={e => setSearch(e.target.value)}
              className="pl-9 h-10 border-slate-200 rounded-xl bg-slate-50 focus:bg-white"
            />
          </div>

          <div className="h-[300px] overflow-y-auto pr-2 space-y-2 mb-6">
            {filteredProducts.map(p => (
              <div 
                key={p.id} 
                onClick={() => handleProductSelect(p)}
                className={`p-3 rounded-xl border cursor-pointer transition-all ${
                  selectedProductId === p.id 
                    ? 'border-blue-500 bg-blue-50 ring-1 ring-blue-500' 
                    : 'border-slate-200 hover:border-slate-300 hover:bg-slate-50'
                }`}
              >
                <div className="flex justify-between items-center">
                  <div>
                    <div className="font-medium text-slate-900">{p.name}</div>
                    <div className="text-xs text-slate-500">Kaydka: {p.quantity_on_hand} xabo</div>
                  </div>
                  <div className="font-bold text-emerald-600">${p.selling_price.toFixed(2)}</div>
                </div>
              </div>
            ))}
            {filteredProducts.length === 0 && (
              <div className="text-center py-8 text-slate-500 text-sm">Alaab ma lahan ama kaydka ayaa maran</div>
            )}
          </div>

          <div className="flex items-end gap-3 p-4 bg-slate-50 rounded-xl border border-slate-200">
            <div className="grid gap-1.5 flex-1">
              <Label className="text-xs font-medium text-slate-600">Xabado (Qty)</Label>
              <Input 
                type="number" 
                min="1" 
                value={qtyInput} 
                onChange={e => setQtyInput(e.target.value)}
                className="h-9 bg-white"
                disabled={!selectedProductId}
              />
            </div>
            <div className="grid gap-1.5 flex-1">
              <Label className="text-xs font-medium text-slate-600">Qiimaha / xabo ($)</Label>
              <Input 
                type="number" 
                step="0.01" 
                value={priceInput} 
                onChange={e => setPriceInput(e.target.value)}
                className="h-9 bg-white"
                disabled={!selectedProductId}
              />
            </div>
            <Button 
              type="button" 
              onClick={handleAddToCart} 
              disabled={!selectedProductId}
              className="h-9 bg-blue-600 hover:bg-blue-700 text-white shadow-sm px-6"
            >
              <Plus className="h-4 w-4 mr-2" />
              Add
            </Button>
          </div>
        </div>
      </div>

      {/* RIGHT: CART & CHECKOUT */}
      <div className="lg:col-span-5">
        <form onSubmit={handleSubmit} className="bg-white rounded-2xl border border-slate-200/80 shadow-sm flex flex-col h-full overflow-hidden">
          <div className="p-5 border-b border-slate-100 bg-slate-50/50 flex items-center justify-between">
            <h3 className="font-semibold text-slate-900 flex items-center gap-2">
              <ShoppingCart className="h-5 w-5 text-slate-400" />
              Cart (Liiska)
            </h3>
            <span className="bg-slate-900 text-white text-xs font-bold px-2 py-1 rounded-full">
              {cart.length} items
            </span>
          </div>

          <div className="flex-1 overflow-y-auto p-5 min-h-[250px]">
            {cart.length === 0 ? (
              <div className="flex flex-col items-center justify-center h-full text-slate-400 space-y-3">
                <ShoppingCart className="h-10 w-10 opacity-20" />
                <p className="text-sm">Cart waa maran yahay</p>
              </div>
            ) : (
              <div className="space-y-3">
                {cart.map((item, idx) => (
                  <div key={idx} className="flex justify-between items-center p-3 rounded-xl border border-slate-100 bg-white shadow-sm">
                    <div className="flex-1 min-w-0 pr-3">
                      <p className="text-sm font-medium text-slate-900 truncate">{item.product.name}</p>
                      <p className="text-xs text-slate-500 mt-0.5">
                        {item.quantity} x ${item.price.toFixed(2)}
                      </p>
                    </div>
                    <div className="flex items-center gap-3 shrink-0">
                      <span className="font-bold text-slate-900">${(item.quantity * item.price).toFixed(2)}</span>
                      <button 
                        type="button" 
                        onClick={() => removeFromCart(item.product.id)}
                        className="w-7 h-7 flex items-center justify-center text-rose-500 bg-rose-50 hover:bg-rose-100 rounded-md transition-colors"
                      >
                        <Trash2 className="h-3.5 w-3.5" />
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>

          <div className="p-5 border-t border-slate-100 bg-slate-50 space-y-5">
            <div className="flex justify-between items-center">
              <span className="text-slate-500 font-medium">Total Amount</span>
              <span className="text-2xl font-black text-emerald-600">${totalAmount.toFixed(2)}</span>
            </div>

            <div className="space-y-4 pt-4 border-t border-slate-200">
              <div>
                <Label className="text-xs font-semibold text-slate-700 uppercase tracking-wider mb-3 block">Customer Info</Label>
                <div className="flex items-center gap-4 mb-3">
                  <label className="flex items-center gap-2 text-sm cursor-pointer">
                    <input type="radio" checked={isWalkIn} onChange={() => setIsWalkIn(true)} className="text-blue-600 focus:ring-blue-500" />
                    Walk-in (Caadi)
                  </label>
                  <label className="flex items-center gap-2 text-sm cursor-pointer">
                    <input type="radio" checked={!isWalkIn} onChange={() => setIsWalkIn(false)} className="text-blue-600 focus:ring-blue-500" />
                    Macmiil Diiwaangashan
                  </label>
                </div>

                {!isWalkIn && (
                  <div className="space-y-3 p-3 bg-white rounded-xl border border-slate-200">
                    <select 
                      value={customerId} 
                      onChange={e => setCustomerId(e.target.value)}
                      className="w-full text-sm h-9 border-slate-200 rounded-md focus:border-slate-900 focus:ring-0"
                    >
                      <option value="">-- Dooro Macmiil (Existing) --</option>
                      {customers.map(c => <option key={c.id} value={c.id}>{c.name} {c.phone ? `(${c.phone})` : ''}</option>)}
                    </select>
                    <div className="relative">
                      <div className="absolute inset-0 flex items-center"><div className="w-full border-t border-slate-100"></div></div>
                      <div className="relative flex justify-center text-xs uppercase"><span className="bg-white px-2 text-slate-400">Ama (OR)</span></div>
                    </div>
                    <Input 
                      placeholder="Qor magac macmiil cusub..." 
                      value={customerNameRaw}
                      onChange={e => setCustomerNameRaw(e.target.value)}
                      className="h-9 text-sm border-slate-200 focus:border-slate-900"
                    />
                  </div>
                )}
              </div>

              <div>
                <Label className="text-xs font-semibold text-slate-700 uppercase tracking-wider mb-3 block">Payment Status</Label>
                <div className="grid grid-cols-3 gap-2">
                  {[
                    { id: 'paid', label: 'La Bixiyay' },
                    { id: 'partial', label: 'Qayb' },
                    { id: 'credit', label: 'Deyn' }
                  ].map(opt => (
                    <label key={opt.id} className={`flex items-center justify-center p-2 rounded-lg border cursor-pointer text-sm font-medium transition-all ${
                      paymentStatus === opt.id ? 'bg-slate-900 text-white border-slate-900' : 'bg-white text-slate-600 border-slate-200 hover:border-slate-300'
                    }`}>
                      <input type="radio" className="sr-only" checked={paymentStatus === opt.id} onChange={() => setPaymentStatus(opt.id)} />
                      {opt.label}
                    </label>
                  ))}
                </div>

                {paymentStatus === 'partial' && (
                  <div className="mt-3">
                    <Input 
                      type="number" step="0.01" max={totalAmount} required
                      placeholder="Imisa ayaa la bixiyay? ($)" 
                      value={amountPaid} onChange={e => setAmountPaid(e.target.value)}
                      className="h-10 text-sm border-slate-200 focus:border-slate-900 bg-white"
                    />
                  </div>
                )}
              </div>
            </div>

            {error && <div className="text-sm text-rose-600 bg-rose-50 p-3 rounded-lg border border-rose-200">{error}</div>}

            <Button type="submit" disabled={loading} className="w-full h-12 bg-emerald-600 hover:bg-emerald-700 text-white text-lg font-bold rounded-xl shadow-lg shadow-emerald-600/20">
              {loading ? "Wuu Iibinayaa..." : "Iibi Hadda (Complete Sale)"}
            </Button>
          </div>
        </form>
      </div>
    </div>
  );
}
