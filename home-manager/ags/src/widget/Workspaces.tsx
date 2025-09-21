import { Gdk } from "ags/gtk4";
import AstalHyprland from "gi://AstalHyprland";
import { createBinding, For } from "ags";

export function Workspaces({ gdkmonitor }: { gdkmonitor: Gdk.Monitor }) {
  const hyprland = AstalHyprland.get_default();
  const activeWorkspaceId = createBinding(
    hyprland,
    "focusedWorkspace",
  )((ws) => ws?.id);

  const workspaces = createBinding(
    hyprland,
    "workspaces",
  )((workspaces) =>
    workspaces
      .filter((ws) => {
        return ws.monitor?.name === gdkmonitor.connector;
      })
      .sort((a, b) => a.id - b.id),
  );

  const handleWorkspaceClick = (id: number) => {
    hyprland.dispatch("workspace", id.toString());
  };

  return (
    <box cssName="workspaces">
      <For each={workspaces}>
        {(workspace) => (
          <button
            onClicked={() => handleWorkspaceClick(workspace.id)}
            class={activeWorkspaceId((activeId) =>
              activeId === workspace.id ? "focused" : "",
            )}
          >
            <label label={workspace.id.toString()} />
          </button>
        )}
      </For>
    </box>
  );
}
