import { cn } from "@/lib/utils"
import { ReactNode } from "react"

interface PageHeaderProps {
  title: string
  description?: string
  action?: ReactNode
}

export function PageHeader({ title, description, action }: PageHeaderProps) {
  return (
    <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pb-2">
      <div>
        <h2 className="text-2xl font-bold tracking-tight text-slate-900">{title}</h2>
        {description && <p className="text-slate-500 text-sm mt-0.5">{description}</p>}
      </div>
      {action && <div className="shrink-0">{action}</div>}
    </div>
  )
}

interface StatCardProps {
  title: string
  value: string | number
  description?: string
  icon?: ReactNode
  className?: string
  highlight?: "green" | "red" | "amber" | "blue"
}

export function StatCard({ title, value, description, icon, className, highlight }: StatCardProps) {
  const highlightClass = {
    green: "text-emerald-600",
    red: "text-rose-600",
    amber: "text-amber-600",
    blue: "text-blue-600",
  }[highlight ?? "blue"] ?? ""

  return (
    <div className={cn("bg-white rounded-2xl border border-slate-200/80 p-5 shadow-sm card-hover", className)}>
      <div className="flex items-start justify-between mb-3">
        <p className="text-sm font-medium text-slate-600">{title}</p>
        {icon && <div className="text-slate-400">{icon}</div>}
      </div>
      <div className={cn("text-2xl font-bold text-slate-900", highlightClass)}>{value}</div>
      {description && <p className="text-xs text-slate-400 mt-1">{description}</p>}
    </div>
  )
}

interface DataTableWrapperProps {
  children: ReactNode
  className?: string
}

export function DataTableWrapper({ children, className }: DataTableWrapperProps) {
  return (
    <div className={cn("bg-white rounded-2xl border border-slate-200/80 shadow-sm overflow-hidden", className)}>
      {children}
    </div>
  )
}

interface EmptyStateProps {
  icon?: ReactNode
  title: string
  description?: string
}

export function EmptyState({ icon, title, description }: EmptyStateProps) {
  return (
    <div className="flex flex-col items-center justify-center py-16 px-4 text-center">
      {icon && <div className="text-slate-300 mb-3">{icon}</div>}
      <p className="text-sm font-medium text-slate-500">{title}</p>
      {description && <p className="text-xs text-slate-400 mt-1">{description}</p>}
    </div>
  )
}

interface ErrorStateProps {
  message: string
  colSpan?: number
}

export function ErrorRow({ message, colSpan = 6 }: ErrorStateProps) {
  return (
    <tr>
      <td colSpan={colSpan} className="px-6 py-8 text-center text-sm text-rose-600 bg-rose-50/50">
        ⚠️ {message}
      </td>
    </tr>
  )
}
