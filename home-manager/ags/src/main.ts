import GObject from 'gi://GObject';
import Gtk from 'gi://Gtk';

const hyprland = await Service.import("hyprland");
const notifications = await Service.import("notifications");
const audio = await Service.import("audio");
const systemtray = await Service.import("systemtray");

const date = Variable("", {
  poll: [1000, 'date "+%H:%M:%S - %e %b."'],
});

const monitors: Monitor[] = JSON.parse(Utils.exec('hyprctl -j monitors'));

interface Monitor {
  id: number;
  name: string;
}

function Workspaces(monitor: Monitor) {
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

function Clock() {
    const calendar = Widget.Calendar({ show_day_names: true, show_heading: true });
    
    const calendarWindow = Widget.Window({
        name: 'calendar',
        anchor: ['top', 'right'],
        visible: false,
        child: calendar,
    });

    return Widget.Box({
        children: [
            Widget.Button({
                on_clicked: () => {
                    calendarWindow.visible = !calendarWindow.visible;
                },
                class_name: "clock",
                child: Widget.Label({
                  class_name: "clock",
                  label: date.bind(),
                }),
            }),
        ],
    });
}

function Notification() {
    const popups = notifications.bind("popups");
    return Widget.Box({
        class_name: "notification",
        visible: popups.as(p => p.length > 0),
        children: [
            Widget.Icon({
                icon: "preferences-system-notifications-symbolic",
            }),
            Widget.Label({
                label: popups.as(p => p[0]?.summary || ""),
            }),
        ],
    });
}

function Volume() {
    const icons: { [key: number]: string } = {
        101: "overamplified",
        67: "high",
        34: "medium",
        1: "low",
        0: "muted",
    };

    function getIcon(): string {
        const icon = audio.speaker.is_muted ? 0 : [101, 67, 34, 1, 0].find(
            threshold => threshold <= (audio.speaker.volume * 100)) || 0;

        return `audio-volume-${icons[icon]}-symbolic`;
    }

    const icon = Widget.Icon({
        icon: Utils.watch(getIcon(), audio.speaker, getIcon),
    });

    const slider = Widget.Slider({
        hexpand: true,
        draw_value: false,
        on_change: ({ value }) => audio.speaker.volume = value,
        setup: self => self.hook(audio.speaker, () => {
            self.value = audio.speaker.volume || 0;
        }),
    });

    return Widget.Box({
        class_name: "volume",
        css: "min-width: 180px",
        children: [icon, slider],
    });
}

function SysTray() {
    const items = systemtray.bind("items")
        .as(items => items.map(item => Widget.Button({
            child: Widget.Icon({ icon: item.bind("icon") }),
            on_primary_click: (_, event) => item.activate(event),
            on_secondary_click: (_, event) => item.openMenu(event),
            tooltip_markup: item.bind("tooltip_markup"),
        })));

    return Widget.Box({
        children: items,
    });
}

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

function Bar(monitor: Monitor) {
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

App.config({
    style: "./style.css",
    windows: monitors.map(monitor => Bar(monitor)),
});

export {};
