import { App, Astal, Gtk, Gdk } from "astal/gtk3"
import { execAsync } from "astal"

function PowerButton({ icon, label, command, className = "" }: {
    icon: string
    label: string
    command: string
    className?: string
}) {
    return <button
        className={`power-button ${className}`}
        onClicked={() => {
            App.toggle_window("powermenu")
            execAsync(["bash", "-c", command])
        }}>
        <box vertical>
            <icon icon={icon} />
            <label label={label} />
        </box>
    </button>
}

export default function PowerMenu() {
    return <window
        name="powermenu"
        className="PowerMenu"
        visible={false}
        keymode={Astal.Keymode.EXCLUSIVE}
        exclusivity={Astal.Exclusivity.IGNORE}
        anchor={Astal.WindowAnchor.TOP | Astal.WindowAnchor.BOTTOM | Astal.WindowAnchor.LEFT | Astal.WindowAnchor.RIGHT}
        onKeyPressEvent={(_, event) => {
            if (event.get_keyval()[1] === Gdk.KEY_Escape) {
                App.toggle_window("powermenu")
            }
        }}>
        <box className="container" halign={Gtk.Align.CENTER} valign={Gtk.Align.CENTER}>
            <PowerButton
                icon="system-lock-screen-symbolic"
                label="Lock"
                command="hyprlock"
            />
            <PowerButton
                icon="system-log-out-symbolic"
                label="Logout"
                command="hyprctl dispatch exit"
            />
            <PowerButton
                icon="system-suspend-symbolic"
                label="Suspend"
                command="systemctl suspend"
            />
            <PowerButton
                icon="system-reboot-symbolic"
                label="Reboot"
                command="systemctl reboot"
            />
            <PowerButton
                icon="system-shutdown-symbolic"
                label="Shutdown"
                command="systemctl poweroff"
                className="shutdown"
            />
        </box>
    </window>
}
