"use client"

import { useRouter, useSearchParams } from "next/navigation"
import { useCallback } from "react"
import { LiveSearch } from "@/components/ui/live-search"
import { X } from "lucide-react"

export function CreditFilters({ currentDate }: { currentDate: string }) {
  const router = useRouter()
  const searchParams = useSearchParams()

  const handleDateChange = useCallback(
    (e: React.ChangeEvent<HTMLInputElement>) => {
      const params = new URLSearchParams(searchParams.toString())
      if (e.target.value) {
        params.set("date", e.target.value)
      } else {
        params.delete("date")
      }
      router.push(`/credit?${params.toString()}`)
    },
    [router, searchParams]
  )

  const clearDate = useCallback(() => {
    const params = new URLSearchParams(searchParams.toString())
    params.delete("date")
    router.push(`/credit?${params.toString()}`)
  }, [router, searchParams])

  return (
    <div className="flex flex-wrap items-center gap-3">
      <div className="w-full sm:w-64">
        <LiveSearch placeholder="Raadi Macmiil..." />
      </div>
      <div className="flex items-center gap-2">
        <input
          type="date"
          value={currentDate}
          onChange={handleDateChange}
          className="h-10 px-3 py-2 text-sm rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-slate-900 focus:border-transparent text-slate-700 bg-white"
          title="Taariikh ka dooro"
        />
        {currentDate && (
          <button
            onClick={clearDate}
            className="flex items-center gap-1 text-xs text-rose-500 hover:text-rose-700 bg-rose-50 hover:bg-rose-100 px-2 py-1.5 rounded-lg transition-colors"
            title="Nadiifi (Clear filter)"
          >
            <X className="h-3 w-3" />
            Nadiifi
          </button>
        )}
      </div>
    </div>
  )
}
