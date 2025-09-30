import { createState } from "ags";

export const [notificationsEnabled, setNotificationsEnabled] =
  createState(true);

export default function ToggleNotification() {
  const toggleNotifications = () => {
    setNotificationsEnabled(!notificationsEnabled.get());
  };

  return (
    <button class="toggle-notification" onClicked={toggleNotifications}>
      <image
        iconName={notificationsEnabled((enabled) =>
          enabled ? "notification-symbolic" : "notification-disabled-symbolic",
        )}
      />
    </button>
  );
}
