"""
Top Bar Widget - GNOME-like bar
"""
from ignis.widgets import Widget
from ignis.services.hyprland import HyprlandService

from ..Clock import Clock
from util import popup_manager

hyprland = HyprlandService.get_default()


class Bar(Widget.Window):
    def __init__(self, monitor: int = 0):
        self.monitor = monitor
        self._clock_hovered = False
        self._tray_hovered = False

        super().__init__(
            namespace=f"ignis_bar_{monitor}",
            monitor=monitor,
            anchor=["left", "top", "right"],
            exclusivity="exclusive",
            layer="top",
            child=Widget.EventBox(
                on_click=self._on_click,
                child=Widget.CenterBox(
                    css_classes=["bar"],
                    start_widget=self._left_section(),
                    center_widget=self._center_section(),
                    end_widget=self._right_section(),
                ),
            ),
        )

    def _left_section(self) -> Widget.Box:
        return Widget.Box(
            css_classes=["bar-left"],
            spacing=8,
            children=[
                # Workspaces will go here
            ],
        )

    def _center_section(self) -> Widget.Box:
        return Widget.EventBox(
            on_hover=lambda *_: setattr(self, "_clock_hovered", True),
            on_hover_lost=lambda *_: setattr(self, "_clock_hovered", False),
            child=Clock(),
        )

    def _right_section(self) -> Widget.Box:
        return Widget.EventBox(
            on_hover=lambda *_: setattr(self, "_tray_hovered", True),
            on_hover_lost=lambda *_: setattr(self, "_tray_hovered", False),
            child=Widget.Box(
                css_classes=["bar-right"],
                spacing=8,
                children=[
                    Widget.Button(
                        css_classes=["bar-tray-button"],
                        child=Widget.Icon(icon_name="preferences-system-symbolic", pixel_size=16),
                        on_click=lambda *_: popup_manager.toggle_popup(f"control_centre_{self.monitor}"),
                    ),
                ],
            ),
        )

    def _on_click(self, *_):
        if self._clock_hovered:
            popup_manager.toggle_popup(f"notifs_calendar_{self.monitor}")
        elif self._tray_hovered:
            popup_manager.toggle_popup(f"control_centre_{self.monitor}")
