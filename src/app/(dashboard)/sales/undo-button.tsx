"use client"

import { useState } from "react"
import { Button } from "@/components/ui/button"
import { Undo2, Loader2 } from "lucide-react"
import { undoSale } from "./actions"
import { useToast } from "@/hooks/use-toast"

export function UndoButton({ saleId }: { saleId: string }) {
  const [isPending, setIsPending] = useState(false)
  const { toast } = useToast()

  async function handleUndo() {
    if (!confirm("Ma hubtaa inaad rabto inaad iibkan ka noqoto (Undo)? Alaabtu waxay ku laaban doontaa stock-ga.")) {
      return
    }
    
    setIsPending(true)
    try {
      await undoSale(saleId)
      toast({
        title: "Waa lagu guulaystay",
        description: "Iibkii waa la tirtiray oo alaabtii stock-ga ayaa lagu celiyay.",
        variant: "default",
        className: "bg-emerald-50 text-emerald-900 border-emerald-200"
      })
    } catch (error: any) {
      toast({
        title: "Cillad ayaa dhacday",
        description: error.message || "Waa lagu guuldareystay in la tirtiro iibka.",
        variant: "destructive"
      })
    } finally {
      setIsPending(false)
    }
  }

  return (
    <Button
      onClick={handleUndo}
      disabled={isPending}
      variant="outline"
      size="sm"
      className="text-rose-600 border-rose-200 hover:bg-rose-50"
      title="Undo Sale (Celinta Alaabta)"
    >
      {isPending ? <Loader2 className="h-4 w-4 mr-2 animate-spin" /> : <Undo2 className="h-4 w-4 mr-2" />}
      Undo
    </Button>
  )
}
