import { bind } from "astal"
import Battery from "gi://AstalBattery"

export default function BatteryWidget() {
    const bat = Battery.get_default()

    return <box className="Battery" visible={bind(bat, "isPresent")}>
        <icon icon={bind(bat, "iconName")} />
        <label label={bind(bat, "percentage").as(p =>
            `${Math.round(p * 100)}%`
        )} />
    </box>
}
