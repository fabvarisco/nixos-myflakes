import { Astal, Gtk, Gdk } from "astal/gtk3"
import Workspaces from "./Workspaces"
import Clock from "./Clock"
import SystemTray from "./SystemTray"
import Battery from "./Battery"
import Audio from "./Audio"
import Network from "./Network"
import Mpris from "./Mpris"
import Taskbar from "./Taskbar"

export default function Bar(gdkmonitor: Gdk.Monitor) {
    const anchor = Astal.WindowAnchor.TOP
        | Astal.WindowAnchor.LEFT
        | Astal.WindowAnchor.RIGHT

    return <window
        className="Bar"
        gdkmonitor={gdkmonitor}
        exclusivity={Astal.Exclusivity.EXCLUSIVE}
        anchor={anchor}>
        <centerbox>
            <box className="left" hexpand halign={Gtk.Align.START}>
                <Workspaces />
                <Taskbar />
            </box>
            <box className="center">
                <Mpris />
            </box>
            <box className="right" hexpand halign={Gtk.Align.END}>
                <SystemTray />
                <Network />
                <Audio />
                <Battery />
                <Clock />
            </box>
        </centerbox>
    </window>
}
