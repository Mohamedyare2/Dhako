"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { createClient } from "@/lib/supabase/client";
import { Trash2, Plus, Search, ShoppingCart, Printer, CheckCircle2, X, FileText, Tag } from "lucide-react";

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

interface ReceiptData {
  saleId: string;
  date: string;
  customerName: string;
  items: { name: string; quantity: number; price: number; subtotal: number }[];
  totalAmount: number;
  amountPaid: number;
  change: number;
  paymentStatus: string;
}

export default function NewSaleForm({ products, customers }: { products: Product[], customers: Customer[] }) {
  const router = useRouter();
  const supabase = createClient();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  // Receipt state
  const [receipt, setReceipt] = useState<ReceiptData | null>(null);

  // Cart state
  const [cart, setCart] = useState<{ product: Product, quantity: number, price: number }[]>([]);
  const [selectedProductId, setSelectedProductId] = useState("");
  const [qtyInput, setQtyInput] = useState("1");
  const [priceInput, setPriceInput] = useState("");

  // Sale metadata
  const [isWalkIn, setIsWalkIn] = useState(true);
  const [customerId, setCustomerId] = useState("");
  const [customerNameRaw, setCustomerNameRaw] = useState("");
  const [paymentStatus, setPaymentStatus] = useState("paid");
  const [amountPaid, setAmountPaid] = useState("");
  const [discountPercent, setDiscountPercent] = useState(0);
  const [showQuotation, setShowQuotation] = useState(false);

  // Search filter
  const [search, setSearch] = useState("");
  const [customerSearch, setCustomerSearch] = useState("");

  const filteredProducts = products.filter(p =>
    p.name.toLowerCase().includes(search.toLowerCase()) && p.quantity_on_hand > 0
  );

  const filteredCustomers = customers.filter(c =>
    c.name.toLowerCase().includes(customerSearch.toLowerCase())
  );

  const subtotalAmount = cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);
  const discountAmount = subtotalAmount * (discountPercent / 100);
  const totalAmount = subtotalAmount - discountAmount;

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

      // Determine customer display name
      let customerDisplay = "Macmiil Caadi (Walk-in)";
      if (!isWalkIn) {
        if (customerId) {
          const found = customers.find(c => c.id === customerId);
          customerDisplay = found ? found.name : "Macmiil";
        } else if (customerNameRaw) {
          customerDisplay = customerNameRaw;
        }
      }

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

      // 2. Create Sale Items
      const saleItems = cart.map(item => ({
        sale_id: saleData.id,
        product_id: item.product.id,
        product_name_raw: item.product.name,
        quantity: item.quantity,
        unit_price: item.price,
        total_price: item.quantity * item.price
      }));

      const { error: itemsError } = await supabase.from("sale_items").insert(saleItems);
      if (itemsError) throw new Error(itemsError.message);

      // 3. Update products stock
      for (const item of cart) {
        const { error: updateError } = await supabase.rpc('decrement_product_quantity', {
          p_id: item.product.id,
          p_quantity: item.quantity
        });

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
          customer_name_raw: finalCustomerRaw || customerDisplay,
          amount_owed: totalAmount,
          amount_paid: paidAmt,
          status: 'open',
          description: `Deyn iib: ${cart.map(c => c.product.name).join(", ")}`
        });
        if (creditError) throw new Error(creditError.message);
      }

      // 5. Show receipt instead of redirecting
      const change = paymentStatus === 'paid' ? 0 : (paidAmt > totalAmount ? paidAmt - totalAmount : 0);
      setReceipt({
        saleId: saleData.id.slice(0, 8).toUpperCase(),
        date: new Date().toLocaleString('so-SO', { dateStyle: 'full', timeStyle: 'short' }),
        customerName: customerDisplay,
        items: cart.map(item => ({
          name: item.product.name,
          quantity: item.quantity,
          price: item.price,
          subtotal: item.quantity * item.price
        })),
        totalAmount,
        amountPaid: paidAmt,
        change,
        paymentStatus
      });

      setLoading(false);

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    } catch (err: any) {
      setError(err.message || "Waxaa dhacday cillad");
      setLoading(false);
    }
  };

  const handlePrint = () => {
    window.print();
  };

  const handleNewSale = () => {
    setReceipt(null);
    setCart([]);
    setCustomerId("");
    setCustomerNameRaw("");
    setAmountPaid("");
    setPaymentStatus("paid");
    setIsWalkIn(true);
    setDiscountPercent(0);
    setShowQuotation(false);
    setCustomerSearch("");
    router.refresh();
  };

  // ===================== RECEIPT MODAL =====================
  if (receipt) {
    const statusLabel = receipt.paymentStatus === 'paid' ? 'La Bixiyay' : receipt.paymentStatus === 'credit' ? 'Deyn' : 'Qayb Bixiyay';
    const statusColor = receipt.paymentStatus === 'paid' ? 'text-emerald-600' : receipt.paymentStatus === 'credit' ? 'text-rose-600' : 'text-amber-600';

    return (
      <div className="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 flex items-center justify-center p-4 print:bg-white print:p-0">
        <div className="bg-white rounded-2xl shadow-2xl w-full max-w-md overflow-hidden print:shadow-none print:rounded-none print:max-w-none" id="receipt">
          {/* Header */}
          <div className="bg-slate-900 text-white p-6 text-center print:bg-slate-900">
            <div className="w-14 h-14 bg-white/10 rounded-2xl flex items-center justify-center mx-auto mb-3">
              <CheckCircle2 className="h-8 w-8 text-emerald-400" />
            </div>
            <h2 className="text-xl font-bold">Dhako POS</h2>
            <p className="text-slate-400 text-sm mt-1">Rasiidhka Iibka (Receipt)</p>
          </div>

          {/* Receipt Body */}
          <div className="p-6 space-y-4">
            {/* Sale Info */}
            <div className="flex justify-between text-sm">
              <span className="text-slate-500">Lambarka Iibka</span>
              <span className="font-mono font-bold text-slate-900">#{receipt.saleId}</span>
            </div>
            <div className="flex justify-between text-sm">
              <span className="text-slate-500">Taariikhda</span>
              <span className="font-medium text-slate-700 text-right text-xs">{receipt.date}</span>
            </div>
            <div className="flex justify-between text-sm">
              <span className="text-slate-500">Macmiilka</span>
              <span className="font-semibold text-slate-900">{receipt.customerName}</span>
            </div>

            <div className="border-t border-dashed border-slate-200 my-3" />

            {/* Items */}
            <div className="space-y-2">
              <p className="text-xs font-semibold text-slate-500 uppercase tracking-wider">Alaabta La Iibiyay</p>
              {receipt.items.map((item, i) => (
                <div key={i} className="flex justify-between items-start text-sm">
                  <div className="flex-1 pr-4">
                    <p className="font-medium text-slate-900">{item.name}</p>
                    <p className="text-xs text-slate-400">{item.quantity} × ${item.price.toFixed(2)}</p>
                  </div>
                  <span className="font-semibold text-slate-900">${item.subtotal.toFixed(2)}</span>
                </div>
              ))}
            </div>

            <div className="border-t border-dashed border-slate-200 my-3" />

            {/* Totals */}
            <div className="space-y-2">
              <div className="flex justify-between text-sm">
                <span className="text-slate-500">Wadarta Guud</span>
                <span className="font-bold text-slate-900">${receipt.totalAmount.toFixed(2)}</span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-slate-500">La Bixiyay</span>
                <span className="font-bold text-slate-900">${receipt.amountPaid.toFixed(2)}</span>
              </div>
              {receipt.change > 0 && (
                <div className="flex justify-between text-sm">
                  <span className="text-slate-500">Khasaaraha</span>
                  <span className="font-bold text-emerald-600">${receipt.change.toFixed(2)}</span>
                </div>
              )}
              <div className="flex justify-between items-center pt-2 border-t border-slate-200">
                <span className="text-sm text-slate-500">Xaaladda Lacagta</span>
                <span className={`text-sm font-bold ${statusColor}`}>{statusLabel}</span>
              </div>
            </div>

            <div className="border-t border-dashed border-slate-200 my-3" />

            <p className="text-center text-xs text-slate-400">
              Mahadsanid! Thank you for your purchase.
            </p>
          </div>

          {/* Action Buttons */}
          <div className="p-4 border-t border-slate-100 flex gap-3 print:hidden">
            <Button
              onClick={handlePrint}
              className="flex-1 bg-slate-900 hover:bg-slate-800 text-white h-11 rounded-xl font-medium"
            >
              <Printer className="h-4 w-4 mr-2" />
              Daabac (Print)
            </Button>
            <Button
              onClick={handleNewSale}
              variant="outline"
              className="flex-1 h-11 rounded-xl border-slate-200 font-medium"
            >
              <X className="h-4 w-4 mr-2" />
              Iib Cusub
            </Button>
          </div>
        </div>
      </div>
    );
  }

  // ===================== QUOTATION MODAL =====================
  if (showQuotation) {
    const quotCustomer = !isWalkIn
      ? (customerId ? customers.find(c => c.id === customerId)?.name || "Macmiil" : customerNameRaw || "Macmiil")
      : "Walk-in Customer";

    return (
      <div className="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 flex items-center justify-center p-4 print:bg-white print:p-0">
        <div className="bg-white rounded-2xl shadow-2xl w-full max-w-md overflow-hidden print:shadow-none print:rounded-none print:max-w-none" id="quotation">
          {/* Header */}
          <div className="bg-slate-900 text-white p-6 text-center print:bg-slate-900">
            <div className="w-14 h-14 bg-white/10 rounded-2xl flex items-center justify-center mx-auto mb-3">
              <FileText className="h-8 w-8 text-blue-400" />
            </div>
            <h2 className="text-xl font-bold">Dhako POS</h2>
            <p className="text-slate-400 text-sm mt-1">Warqadda Qiimaha (Quotation)</p>
          </div>

          {/* Quotation Body */}
          <div className="p-6 space-y-4">
            <div className="flex justify-between text-sm">
              <span className="text-slate-500">Taariikhda</span>
              <span className="font-medium text-slate-700 text-right text-xs">
                {new Date().toLocaleString('so-SO', { dateStyle: 'full', timeStyle: 'short' })}
              </span>
            </div>
            <div className="flex justify-between text-sm">
              <span className="text-slate-500">Macmiilka</span>
              <span className="font-semibold text-slate-900">{quotCustomer}</span>
            </div>

            <div className="border-t border-dashed border-slate-200 my-3" />

            {/* Items */}
            <div className="space-y-2">
              <p className="text-xs font-semibold text-slate-500 uppercase tracking-wider">Liiska Alaabta</p>
              <div className="grid grid-cols-12 text-xs font-semibold text-slate-400 pb-1 border-b border-slate-100">
                <span className="col-span-5">Alaabta</span>
                <span className="col-span-2 text-center">Qty</span>
                <span className="col-span-2 text-right">Qiimaha</span>
                <span className="col-span-3 text-right">Wadarta</span>
              </div>
              {cart.map((item, i) => (
                <div key={i} className="grid grid-cols-12 text-sm items-center">
                  <span className="col-span-5 font-medium text-slate-900 text-xs">{item.product.name}</span>
                  <span className="col-span-2 text-center text-slate-500">{item.quantity}</span>
                  <span className="col-span-2 text-right text-slate-600">${item.price.toFixed(2)}</span>
                  <span className="col-span-3 text-right font-semibold text-slate-900">${(item.quantity * item.price).toFixed(2)}</span>
                </div>
              ))}
            </div>

            <div className="border-t border-dashed border-slate-200 my-3" />

            {/* Totals */}
            <div className="space-y-2">
              <div className="flex justify-between text-sm">
                <span className="text-slate-500">Wadarta Asal (Subtotal)</span>
                <span className="font-semibold text-slate-900">${subtotalAmount.toFixed(2)}</span>
              </div>
              {discountPercent > 0 && (
                <>
                  <div className="flex justify-between text-sm">
                    <span className="text-slate-500 flex items-center gap-1"><Tag className="h-3 w-3" />Qiimo Dhimis ({discountPercent}%)</span>
                    <span className="font-semibold text-rose-500">-${discountAmount.toFixed(2)}</span>
                  </div>
                  <div className="flex justify-between items-center pt-2 border-t border-slate-200">
                    <span className="text-sm font-bold text-slate-700">Wadarta Dhammaad</span>
                    <span className="text-lg font-black text-emerald-600">${totalAmount.toFixed(2)}</span>
                  </div>
                </>
              )}
              {discountPercent === 0 && (
                <div className="flex justify-between items-center pt-2 border-t border-slate-200">
                  <span className="text-sm font-bold text-slate-700">Wadarta Guud</span>
                  <span className="text-lg font-black text-emerald-600">${totalAmount.toFixed(2)}</span>
                </div>
              )}
            </div>

            <div className="border-t border-dashed border-slate-200 my-3" />
            <p className="text-center text-xs text-slate-400">Warqaddan waxay muujinaysaa qiimaha alaabta. Mahadsanid!</p>
          </div>

          {/* Action Buttons */}
          <div className="p-4 border-t border-slate-100 flex gap-3 print:hidden">
            <Button
              onClick={() => window.print()}
              className="flex-1 bg-slate-900 hover:bg-slate-800 text-white h-11 rounded-xl font-medium"
            >
              <Printer className="h-4 w-4 mr-2" />
              Daabac (Print)
            </Button>
            <Button
              onClick={() => setShowQuotation(false)}
              variant="outline"
              className="flex-1 h-11 rounded-xl border-slate-200 font-medium"
            >
              <X className="h-4 w-4 mr-2" />
              Ku Noqo
            </Button>
          </div>
        </div>
      </div>
    );
  }

  // ===================== SALE FORM =====================
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
            {/* Subtotal & Discount */}
            <div className="space-y-2">
              {discountPercent > 0 && (
                <div className="flex justify-between items-center text-sm">
                  <span className="text-slate-500">Wadarta Asal</span>
                  <span className="font-semibold text-slate-600">${subtotalAmount.toFixed(2)}</span>
                </div>
              )}
              {discountPercent > 0 && (
                <div className="flex justify-between items-center text-sm">
                  <span className="text-slate-500 flex items-center gap-1"><Tag className="h-3.5 w-3.5 text-rose-400" />Qiimo Dhimis ({discountPercent}%)</span>
                  <span className="font-semibold text-rose-500">-${discountAmount.toFixed(2)}</span>
                </div>
              )}
              <div className="flex justify-between items-center">
                <span className="text-slate-500 font-medium">Total Amount</span>
                <span className="text-2xl font-black text-emerald-600">${totalAmount.toFixed(2)}</span>
              </div>
            </div>

            {/* Discount input */}
            <div className="flex items-center gap-2 p-3 bg-white rounded-xl border border-slate-200">
              <Tag className="h-4 w-4 text-slate-400 shrink-0" />
              <Label className="text-xs font-medium text-slate-600 shrink-0">Qiimo Dhimis %</Label>
              <Input
                type="number"
                min={0}
                max={100}
                step={1}
                value={discountPercent || ""}
                onChange={e => setDiscountPercent(Math.min(100, Math.max(0, parseFloat(e.target.value) || 0)))}
                placeholder="0"
                className="h-8 text-sm border-slate-200 focus:border-slate-900 bg-slate-50 flex-1"
              />
              <span className="text-xs text-slate-400 shrink-0">%</span>
            </div>

            {/* Quotation Button */}
            <Button
              type="button"
              onClick={() => {
                if (cart.length === 0) { setError("Fadlan ku dar alaabta cart-ka"); return; }
                setShowQuotation(true);
              }}
              variant="outline"
              className="w-full h-10 rounded-xl border-blue-200 text-blue-700 hover:bg-blue-50 font-medium"
            >
              <FileText className="h-4 w-4 mr-2" />
              Warqadda Qiimaha (Quotation)
            </Button>

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
                    {/* Search box for existing customers */}
                    <div className="relative">
                      <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-slate-400" />
                      <Input
                        type="search"
                        placeholder="Raadi macmiil ku jira..."
                        value={customerSearch}
                        onChange={e => {
                          setCustomerSearch(e.target.value);
                          setCustomerId(""); // reset selection when searching
                        }}
                        className="pl-9 h-9 text-sm border-slate-200 bg-slate-50 focus:bg-white"
                      />
                    </div>
                    <select
                      value={customerId}
                      onChange={e => setCustomerId(e.target.value)}
                      className="w-full text-sm h-9 border-slate-200 rounded-md focus:border-slate-900 focus:ring-0"
                    >
                      <option value="">-- Dooro Macmiil (Existing) --</option>
                      {filteredCustomers.map(c => <option key={c.id} value={c.id}>{c.name} {c.phone ? `(${c.phone})` : ''}</option>)}
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
