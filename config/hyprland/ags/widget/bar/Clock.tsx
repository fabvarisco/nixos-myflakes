import { Variable, GLib } from "astal"

export default function Clock() {
    const time = Variable<string>("").poll(1000, () =>
        GLib.DateTime.new_now_local().format("%H:%M")!)

    const date = Variable<string>("").poll(60000, () =>
        GLib.DateTime.new_now_local().format("%a %d %b")!)

    return <box className="Clock" vertical>
        <label className="time" label={time()} />
        <label className="date" label={date()} />
    </box>
}
