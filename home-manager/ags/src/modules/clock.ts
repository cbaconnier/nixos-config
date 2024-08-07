const date = Variable("", {
  poll: [1000, 'date "+%H:%M:%S - %e %b."'],
});

export function Clock() {
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
