const hyprland = await Service.import("hyprland");

export interface Monitor {
  id: number;
  name: string;
}

export function Workspaces(monitor: Monitor) {
    const activeId = hyprland.active.workspace.bind("id");
    
    const workspaces = hyprland.bind("workspaces")
        .as(ws => ws
          .filter(({monitorID}) => monitorID === monitor.id)
          .sort(({id: a}, {id: b}) => a - b)
          .map(({ id }) => Widget.Button({
            on_clicked: () => hyprland.messageAsync(`dispatch workspace ${id}`),
            child: Widget.Label(`${id}`),
            class_name: activeId.as(i => `${i === id ? "focused" : ""}`),
          }))
        );

    return Widget.Box({
        class_name: "workspaces",
        children: workspaces,
    });
}
