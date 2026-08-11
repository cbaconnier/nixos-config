import { createState } from "ags"

export const [kioskWorkspaceIds, setKioskWorkspaceIds] = createState<
  ReadonlySet<number>
>(new Set())

export function toggleKioskWorkspace(id: number) {
  setKioskWorkspaceIds((ids) => {
    const next = new Set(ids)
    if (next.has(id)) next.delete(id)
    else next.add(id)
    return next
  })
}
