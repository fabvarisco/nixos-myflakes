import { Astal, Gtk, Gdk } from "astal/gtk3"
import { bind, timeout, Variable } from "astal"
import Notifd from "gi://AstalNotifd"

const TIMEOUT_DELAY = 5000

function NotificationIcon({ n }: { n: Notifd.Notification }) {
    if (n.image) {
        return <box
            className="icon"
            css={`background-image: url('${n.image}');`}
        />
    }

    if (n.appIcon) {
        return <icon className="icon" icon={n.appIcon} />
    }

    return <icon className="icon" icon="dialog-information-symbolic" />
}

function Notification({ n }: { n: Notifd.Notification }) {
    return <box className={`Notification ${n.urgency}`} vertical>
        <box className="header">
            <NotificationIcon n={n} />
            <box vertical>
                <label className="title" truncate halign={Gtk.Align.START} label={n.summary} />
                <label className="body" wrap halign={Gtk.Align.START} label={n.body} />
            </box>
            <button className="close" onClicked={() => n.dismiss()}>
                <icon icon="window-close-symbolic" />
            </button>
        </box>
        {n.get_actions().length > 0 && (
            <box className="actions">
                {n.get_actions().map(action => (
                    <button onClicked={() => n.invoke(action.id)}>
                        <label label={action.label} />
                    </button>
                ))}
            </box>
        )}
    </box>
}

export default function NotificationPopups(gdkmonitor: Gdk.Monitor = Gdk.Display.get_default()?.get_primary_monitor()!) {
    const notifd = Notifd.get_default()
    const notifications = new Variable<Notifd.Notification[]>([])

    notifd.connect("notified", (_, id) => {
        const n = notifd.get_notification(id)
        if (n) {
            notifications.set([...notifications.get(), n])
            timeout(TIMEOUT_DELAY, () => {
                notifications.set(notifications.get().filter(notif => notif.id !== id))
            })
        }
    })

    notifd.connect("resolved", (_, id) => {
        notifications.set(notifications.get().filter(n => n.id !== id))
    })

    return <window
        name="notifications"
        className="NotificationPopups"
        gdkmonitor={gdkmonitor}
        exclusivity={Astal.Exclusivity.EXCLUSIVE}
        anchor={Astal.WindowAnchor.TOP | Astal.WindowAnchor.RIGHT}>
        <box vertical>
            {bind(notifications).as(ns => ns.map(n => <Notification n={n} />))}
        </box>
    </window>
}
