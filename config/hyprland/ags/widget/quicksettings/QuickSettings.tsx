import { App, Astal, Gtk, Gdk } from "astal/gtk3"
import { bind } from "astal"
import Wp from "gi://AstalWp"
import Network from "gi://AstalNetwork"
import Bluetooth from "gi://AstalBluetooth"
import PowerProfiles from "gi://AstalPowerProfiles"

function VolumeSlider() {
    const speaker = Wp.get_default()?.audio.defaultSpeaker!

    return <box className="slider-box" vertical>
        <box className="header">
            <icon icon={bind(speaker, "volumeIcon")} />
            <label label="Volume" />
            <label className="value" hexpand halign={Gtk.Align.END}
                label={bind(speaker, "volume").as(v => `${Math.round(v * 100)}%`)} />
        </box>
        <slider
            hexpand
            onDragged={({ value }) => speaker.volume = value}
            value={bind(speaker, "volume")}
        />
    </box>
}

function NetworkToggle() {
    const network = Network.get_default()
    const wifi = network.wifi

    if (!wifi) return <box />

    return <button
        className={bind(wifi, "enabled").as(e => `toggle ${e ? "active" : ""}`)}
        onClicked={() => wifi.enabled = !wifi.enabled}>
        <box>
            <icon icon={bind(wifi, "iconName")} />
            <label label={bind(wifi, "ssid").as(s => s || "Wi-Fi")} />
        </box>
    </button>
}

function BluetoothToggle() {
    const bluetooth = Bluetooth.get_default()

    return <button
        className={bind(bluetooth, "isPowered").as(p => `toggle ${p ? "active" : ""}`)}
        onClicked={() => bluetooth.toggle()}>
        <box>
            <icon icon="bluetooth-symbolic" />
            <label label="Bluetooth" />
        </box>
    </button>
}

function PowerProfilesSelector() {
    const profiles = PowerProfiles.get_default()

    const profileIcons: Record<string, string> = {
        "power-saver": "power-profile-power-saver-symbolic",
        "balanced": "power-profile-balanced-symbolic",
        "performance": "power-profile-performance-symbolic",
    }

    return <box className="power-profiles" vertical>
        <label className="header" halign={Gtk.Align.START} label="Power Profile" />
        <box>
            {["power-saver", "balanced", "performance"].map(profile => (
                <button
                    className={bind(profiles, "activeProfile").as(ap =>
                        `profile ${ap === profile ? "active" : ""}`
                    )}
                    onClicked={() => profiles.activeProfile = profile}>
                    <box vertical>
                        <icon icon={profileIcons[profile]} />
                        <label label={profile.charAt(0).toUpperCase() + profile.slice(1)} />
                    </box>
                </button>
            ))}
        </box>
    </box>
}

export default function QuickSettings() {
    return <window
        name="quicksettings"
        className="QuickSettings"
        visible={false}
        keymode={Astal.Keymode.ON_DEMAND}
        exclusivity={Astal.Exclusivity.EXCLUSIVE}
        anchor={Astal.WindowAnchor.TOP | Astal.WindowAnchor.RIGHT}
        onKeyPressEvent={(_, event) => {
            if (event.get_keyval()[1] === Gdk.KEY_Escape) {
                App.toggle_window("quicksettings")
            }
        }}>
        <box className="container" vertical>
            <box className="toggles">
                <NetworkToggle />
                <BluetoothToggle />
            </box>
            <VolumeSlider />
            <PowerProfilesSelector />
        </box>
    </window>
}
