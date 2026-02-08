"""
Ignis Configuration - GNOME-like desktop shell
"""
import os
from ignis.app import IgnisApp
from ignis.services.hyprland import HyprlandService

# Import widgets
from widgets.Bar import Bar
from widgets.ControlCentre import ControlCentre
from widgets.NotifsCalendar import NotifsCalendar

app = IgnisApp.get_default()
hyprland = HyprlandService.get_default()

CONFIG_DIR = os.path.dirname(os.path.abspath(__file__))

# Load styles
app.apply_css(os.path.join(CONFIG_DIR, "style.scss"))

# Load custom icons (if any)
icons_dir = os.path.join(CONFIG_DIR, "icons")
if os.path.exists(icons_dir):
    app.add_icons(icons_dir)


def init_widgets():
    """Initialize widgets for each monitor"""
    monitors = hyprland.monitors if hyprland.monitors else [None]

    for i, monitor in enumerate(monitors):
        monitor_id = i if monitor is None else i

        # Create widgets for this monitor
        Bar(monitor=monitor_id)
        ControlCentre(monitor=monitor_id)
        NotifsCalendar(monitor=monitor_id)


# Initialize
init_widgets()
