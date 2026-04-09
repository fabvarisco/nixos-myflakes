import { bind } from "astal"
import Hyprland from "gi://AstalHyprland"
import Apps from "gi://AstalApps"

export default function Taskbar() {
    const hypr = Hyprland.get_default()
    const apps = new Apps.Apps()

    return <box className="Taskbar">
        {bind(hypr, "clients").as(clients =>
            clients
                .filter(c => c.workspace.id > 0)
                .map(client => {
                    const app = apps.fuzzy_query(client.class)[0]
                    return <button
                        className={bind(hypr, "focusedClient").as(fc =>
                            client === fc ? "focused" : ""
                        )}
                        tooltipText={bind(client, "title")}
                        onClicked={() => client.focus()}>
                        <icon icon={app?.iconName || "application-x-executable"} />
                    </button>
                })
        )}
    </box>
}
