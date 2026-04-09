import { App } from "astal/gtk3"
import style from "./style/main.scss"
import Bar from "./widget/bar/Bar"
import NotificationPopups from "./widget/notifications/NotificationPopups"
import OSD from "./widget/osd/OSD"
import PowerMenu from "./widget/powermenu/PowerMenu"
import QuickSettings from "./widget/quicksettings/QuickSettings"

App.start({
    css: style,
    instanceName: "hypr",
    requestHandler(request, res) {
        if (request === "notifications") {
            App.toggle_window("notifications")
        } else if (request === "quicksettings") {
            App.toggle_window("quicksettings")
        } else if (request === "powermenu") {
            App.toggle_window("powermenu")
        }
        res("ok")
    },
    main() {
        App.get_monitors().map(Bar)
        NotificationPopups()
        OSD()
        PowerMenu()
        QuickSettings()
    },
})
