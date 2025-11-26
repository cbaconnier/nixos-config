import { Accessor, createState } from "ags"

export const [notificationsEnabled, setNotificationsEnabled] = createState(true)

export default function ToggleNotification({
  visible = true,
}: {
  visible?: boolean | Accessor<boolean>
}) {
  const toggleNotifications = () => {
    setNotificationsEnabled(!notificationsEnabled.get())
  }

  return (
    <button
      class="toggle-notification"
      onClicked={toggleNotifications}
      visible={visible}
    >
      <image
        iconName={notificationsEnabled((enabled) =>
          enabled ? "notification-symbolic" : "notification-disabled-symbolic",
        )}
      />
    </button>
  )
}
