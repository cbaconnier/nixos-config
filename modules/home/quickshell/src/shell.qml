//@ pragma UseQApplication

import Quickshell
import Quickshell.Io
import "."

ShellRoot {
  id: root

  // Workspace ids that hide the bar until hovered
  property var kioskWorkspaces: new Set()

  IpcHandler {
    target: "bar"

    function setKiosk(id: int, enabled: bool): string {
      const next = new Set(root.kioskWorkspaces);
      if (enabled)
        next.add(id);
      else
        next.delete(id);
      root.kioskWorkspaces = next;
      return "ok";
    }

    function listKiosk(): string {
      return Array.from(root.kioskWorkspaces).join(",");
    }
  }

  IpcHandler {
    target: "reminders"

    function alert(title: string, body: string): string {
      Reminders.alert(title, body);
      return "ok";
    }

    function timer(minutes: real, label: string): string {
      Reminders.startTimer(minutes, label);
      return "ok";
    }
  }

  Switcher {
    id: switcher
  }

  IpcHandler {
    target: "switcher"

    function next(): string {
      switcher.step(1);
      return "ok";
    }

    function prev(): string {
      switcher.step(-1);
      return "ok";
    }
  }

  Variants {
    model: Quickshell.screens

    Bar {
      required property var modelData
      screen: modelData
      kioskWorkspaces: root.kioskWorkspaces
    }
  }

  NotificationPopup {}

  ReminderAlerts {}
}
