pragma Singleton

import QtQuick
import QtQml.Models
import Quickshell
import Quickshell.Services.Notifications
import "."

Singleton {
  id: root

  readonly property int historyLimit: 15

  property bool enabled: true
  property int unreadCount: 0

  readonly property ListModel popups: ListModel {}
  readonly property ListModel history: ListModel {}

  NotificationServer {
    id: server

    actionsSupported: true
    bodySupported: true
    imageSupported: true

    onNotification: notif => {
      // Always logged to history, even while muted.
      root.history.insert(0, {
        summary: notif.summary,
        body: notif.body,
        appName: notif.appName,
        appIcon: notif.appIcon,
        image: notif.image
      });
      if (root.history.count > root.historyLimit)
        root.history.remove(root.historyLimit, root.history.count - root.historyLimit);
      root.unreadCount++;

      if (!root.enabled)
        return;

      notif.tracked = true;
      root.popups.append({
        notification: notif,
        read: false
      });

      notif.closed.connect(() => root.remove(notif));
    }
  }

  function remove(notif) {
    for (let i = 0; i < root.popups.count; i++) {
      if (root.popups.get(i).notification === notif) {
        root.popups.remove(i);
        return;
      }
    }
  }

  function markRead() {
    for (let i = 0; i < root.popups.count; i++)
      root.popups.setProperty(i, "read", true);
    root.unreadCount = 0;
  }

  function markOneRead(notif) {
    for (let i = 0; i < root.popups.count; i++) {
      const item = root.popups.get(i);
      if (item.notification === notif) {
        if (!item.read) {
          root.popups.setProperty(i, "read", true);
          root.unreadCount = Math.max(0, root.unreadCount - 1);
        }
        return;
      }
    }
  }

  function clearPopups() {
    for (let i = root.popups.count - 1; i >= 0; i--)
      root.popups.get(i).notification.dismiss();
  }

  function removeHistoryItem(index) {
    root.history.remove(index);
  }

  function clearHistory() {
    root.history.clear();
    root.unreadCount = 0;
  }
}
