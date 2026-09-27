"use client"

import { Search } from "lucide-react"
import { Input } from "./input"
import { useRouter, usePathname, useSearchParams } from "next/navigation"
import { useEffect, useState } from "react"

export function LiveSearch({ placeholder = "Raadi..." }: { placeholder?: string }) {
  const router = useRouter()
  const pathname = usePathname()
  const searchParams = useSearchParams()
  
  const initialQuery = searchParams.get("q") || ""
  const [term, setTerm] = useState(initialQuery)

  useEffect(() => {
    const timer = setTimeout(() => {
      const params = new URLSearchParams(searchParams.toString())
      if (term) {
        params.set("q", term)
      } else {
        params.delete("q")
      }
      router.replace(`${pathname}?${params.toString()}`, { scroll: false })
    }, 300) // 300ms delay to prevent too many requests

    return () => clearTimeout(timer)
  }, [term, pathname, router, searchParams])

  return (
    <div className="relative w-full">
      <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-slate-500" />
      <Input
        type="search"
        value={term}
        onChange={(e) => setTerm(e.target.value)}
        placeholder={placeholder}
        className="pl-9 bg-slate-50 border-slate-300 focus-visible:ring-slate-400"
      />
    </div>
  )
}
