import { bind } from "astal"
import Network from "gi://AstalNetwork"

export default function NetworkWidget() {
    const network = Network.get_default()

    const WifiIndicator = () => {
        const wifi = bind(network, "wifi")
        return <box visible={wifi.as(w => w !== null)}>
            {wifi.as(w => w && (
                <icon icon={bind(w, "iconName")} tooltipText={bind(w, "ssid").as(s => s || "Not connected")} />
            ))}
        </box>
    }

    const WiredIndicator = () => {
        const wired = bind(network, "wired")
        return <box visible={wired.as(w => w !== null)}>
            {wired.as(w => w && (
                <icon icon={bind(w, "iconName")} />
            ))}
        </box>
    }

    return <box className="Network">
        <WifiIndicator />
        <WiredIndicator />
    </box>
}
