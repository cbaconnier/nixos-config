import AstalNotifd from "gi://AstalNotifd";
import { createState } from "ags";
import { notificationsEnabled } from "./ToggleNotification";

export default function Notification() {
  const notifd = AstalNotifd.get_default();

  const [activeNotifications, setActiveNotifications] = createState<
    AstalNotifd.Notification[]
  >([]);

  // Listen for new notifications
  notifd.connect("notified", (_, id) => {
    if (!notificationsEnabled.get()) return;

    const notification = notifd.get_notification(id);
    setActiveNotifications((prev) => [notification, ...prev]);

    // Auto-remove after 5 seconds
    setTimeout(() => {
      setActiveNotifications((prev) => prev.filter((n) => n.id !== id));
    }, 5000);
  });

  // Listen for dismissed notifications
  notifd.connect("resolved", (_, id) => {
    setActiveNotifications((prev) => prev.filter((n) => n.id !== id));
  });

  return (
    <box
      class="notification"
      visible={activeNotifications(
        (notifications) =>
          notifications.length > 0 && notificationsEnabled.get(),
      )}
    >
      <image iconName="notification-symbolic" />
      <label
        label={activeNotifications(
          (notifications) => notifications[0]?.summary || "",
        )}
      />
    </box>
  );
}
