import { Astal, Gtk, Gdk } from "astal/gtk3"
import { bind, Variable, timeout } from "astal"
import Wp from "gi://AstalWp"

const HIDE_DELAY = 2000

export default function OSD(gdkmonitor: Gdk.Monitor = Gdk.Display.get_default()?.get_primary_monitor()!) {
    const speaker = Wp.get_default()?.audio.defaultSpeaker!
    const visible = Variable(false)
    let hideTimeout: any = null

    const show = () => {
        if (hideTimeout) clearTimeout(hideTimeout)
        visible.set(true)
        hideTimeout = timeout(HIDE_DELAY, () => visible.set(false))
    }

    speaker.connect("notify::volume", show)
    speaker.connect("notify::mute", show)

    return <window
        name="osd"
        className="OSD"
        gdkmonitor={gdkmonitor}
        visible={bind(visible)}
        anchor={Astal.WindowAnchor.BOTTOM}>
        <box className="container" vertical>
            <icon icon={bind(speaker, "volumeIcon")} />
            <levelbar
                widthRequest={200}
                value={bind(speaker, "volume")}
            />
            <label label={bind(speaker, "volume").as(v =>
                `${Math.round(v * 100)}%`
            )} />
        </box>
    </window>
}
