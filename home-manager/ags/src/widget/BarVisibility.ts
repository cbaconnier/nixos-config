import { createState } from "ags"

export const [kioskWorkspaceIds, setKioskWorkspaceIds] = createState<
  ReadonlySet<number>
>(new Set())

export function setKioskWorkspace(id: number, enabled: boolean) {
  setKioskWorkspaceIds((ids) => {
    if (ids.has(id) === enabled) return ids
    const next = new Set(ids)
    if (enabled) next.add(id)
    else next.delete(id)
    return next
  })
}
