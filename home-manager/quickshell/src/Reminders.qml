pragma Singleton

import QtQuick
import QtQml.Models
import Quickshell
import Quickshell.Io

Singleton {
  id: root

  readonly property string sound: "/run/current-system/sw/share/sounds/freedesktop/stereo/message-new-instant.oga"
  readonly property string statePath: `${Quickshell.env("HOME")}/.local/state/quickshell-reminders.json`

  readonly property ListModel alerts: ListModel {}
  readonly property ListModel timers: ListModel {}

  readonly property string remindersPath: `${Quickshell.env("HOME")}/.reminders`

  property real now: Date.now()
  property string nextText: ""
  property var upcoming: []
  property var days: ({})

  function alert(title: string, body: string) {
    root.alerts.append({
      title: title,
      body: body,
      muted: false
    });
    if (!player.running && !gap.running)
      player.running = true;
  }

  function ringing(): bool {
    for (let i = 0; i < root.alerts.count; i++)
      if (!root.alerts.get(i).muted)
        return true;
    return false;
  }

  function mute(index: int) {
    root.alerts.setProperty(index, "muted", true);
    if (!root.ringing()) {
      gap.stop();
      player.running = false;
    }
  }

  function dismiss(index: int) {
    root.alerts.remove(index);
    if (root.alerts.count === 0) {
      gap.stop();
      player.running = false;
    }
  }

  function startTimer(minutes: real, label: string) {
    root.timers.append({
      label: label,
      endsAt: Date.now() + minutes * 60000
    });
    root.refresh();
  }

  function cancelTimer(index: int) {
    root.timers.remove(index);
    root.refresh();
  }

  function reload() {
    loader.command = ["remind", "-b2", "-ppp6", root.remindersPath, Qt.formatDate(new Date(), "yyyy-MM-01")];
    loader.running = true;
  }

  function addReminder(date: string, time: string, text: string) {
    const body = text.replace(/[\r\n]+/g, " ").replace(/%/g, "%%").replace(/\[/g, "[char(91)]").replace(/\\+$/, "").trim();
    writer.command = ["sh", "-c", 'printf "%s\\n" "$1" >> "$2"', "sh", `REM ${date} AT ${time} MSG ${body}`, root.remindersPath];
    writer.running = true;
  }

  function removeReminder(line: int) {
    writer.command = ["sed", "-i", `${line}d`, root.remindersPath];
    writer.running = true;
  }

  function format(ms: real): string {
    const total = Math.max(0, Math.ceil(ms / 1000));
    const h = Math.floor(total / 3600);
    const m = Math.floor(total / 60) % 60;
    const s = total % 60;
    const pad = n => String(n).padStart(2, "0");
    return h > 0 ? `${h}:${pad(m)}:${pad(s)}` : `${pad(m)}:${pad(s)}`;
  }

  function refresh() {
    root.now = Date.now();
    let soonest = -1;
    for (let i = root.timers.count - 1; i >= 0; i--) {
      const t = root.timers.get(i);
      if (t.endsAt <= root.now) {
        root.alert(t.label.length > 0 ? t.label : "Minuteur terminé", "");
        root.timers.remove(i);
      } else if (soonest < 0 || t.endsAt < soonest) {
        soonest = t.endsAt;
      }
    }
    root.nextText = soonest < 0 ? "" : root.format(soonest - root.now);
    store.save();
  }

  Timer {
    interval: 1000
    running: root.timers.count > 0
    repeat: true
    onTriggered: root.refresh()
  }

  FileView {
    id: store

    path: root.statePath

    function save() {
      const items = [];
      for (let i = 0; i < root.timers.count; i++) {
        const t = root.timers.get(i);
        items.push({
          label: t.label,
          endsAt: t.endsAt
        });
      }
      store.setText(JSON.stringify(items));
    }

    onLoaded: {
      try {
        for (const t of JSON.parse(store.text()))
          root.timers.append({
            label: t.label,
            endsAt: t.endsAt
          });
      } catch (e) {}
      root.refresh();
    }
  }

  Component.onCompleted: root.reload()

  Process {
    id: player

    command: ["pw-play", root.sound]
    onExited: if (root.ringing())
      gap.restart()
  }

  Timer {
    id: gap

    interval: 500
    onTriggered: if (root.ringing())
      player.running = true
  }

  Process {
    id: writer

    onExited: root.reload()
  }

  Process {
    id: loader

    stdout: StdioCollector {
      onStreamFinished: {
        const nowDate = new Date();
        const today = Qt.formatDate(nowDate, "yyyy-MM-dd");
        const nowMinutes = nowDate.getHours() * 60 + nowDate.getMinutes();
        const days = {};
        const seen = {};
        const items = [];
        try {
          for (const month of JSON.parse(text))
            for (const e of month.entries ?? []) {
              const time = e.time ?? -1;
              const key = `${e.date}|${time}|${e.lineno}`;
              if (seen[key])
                continue;
              seen[key] = true;
              days[e.date] = true;
              if (e.date > today || (e.date === today && time >= nowMinutes))
                items.push({
                  date: e.date,
                  time: time,
                  text: e.body,
                  line: e.lineno
                });
            }
        } catch (e) {}
        items.sort((a, b) => a.date.localeCompare(b.date) || a.time - b.time);
        root.days = days;
        root.upcoming = items;
      }
    }
  }

  FileView {
    path: root.remindersPath
    watchChanges: true
    onFileChanged: root.reload()
  }
}
