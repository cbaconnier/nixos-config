import { Workspaces, Monitor } from './workspaces';
import { Clock } from './clock';
import { Notification } from './notification';
import { Volume } from './volume';
import { SysTray } from './systray';

function Left(monitor: Monitor) {
    return Widget.Box({
        spacing: 8,
        children: [
            Workspaces(monitor),
        ],
    });
}

function Center() {
    return Widget.Box({
        spacing: 8,
        children: [
            Notification(),
        ],
    });
}

function Right() {
    return Widget.Box({
        hpack: "end",
        spacing: 8,
        children: [
            Volume(),
            Clock(),
            SysTray(),
        ],
    });
}

export function Bar(monitor: Monitor) {
    return Widget.Window({
        name: `bar-${monitor.id}`,
        class_name: "bar",
        monitor: monitor.id,
        anchor: ["top", "left", "right"],
        exclusivity: "exclusive",
        child: Widget.CenterBox({
            start_widget: Left(monitor),
            center_widget: Center(),
            end_widget: Right(),
        }),
    });
}
