"""
Control Centre Widget - GNOME-like control panel
"""
from ignis.widgets import Widget
from ignis.services.audio import AudioService
from ignis.services.network import NetworkService
from ignis.services.bluetooth import BluetoothService

from util import popup_manager, adjust_volume

audio = AudioService.get_default()
network = NetworkService.get_default()
bluetooth = BluetoothService.get_default()


class ControlCentreWidget(Widget.Box):
    """Base widget for control centre buttons"""
    def __init__(
        self,
        icon: str,
        label: str,
        secondary_label: str = "",
        on_click=None,
        on_click_other=None,
        active: bool = False,
    ):
        self._active = active

        left_content = Widget.Box(
            spacing=8,
            children=[
                Widget.Icon(icon_name=icon, pixel_size=20),
                Widget.Box(
                    orientation="vertical",
                    children=[
                        Widget.Label(label=label, css_classes=["cc-widget-label"], halign="start"),
                        Widget.Label(
                            label=secondary_label,
                            css_classes=["cc-widget-secondary"],
                            halign="start",
                            visible=bool(secondary_label),
                        ),
                    ],
                ),
            ],
        )

        if on_click_other:
            children = [
                Widget.Button(
                    css_classes=["cc-widget-left", "cc-widget-active" if active else ""],
                    child=left_content,
                    on_click=on_click,
                ),
                Widget.Button(
                    css_classes=["cc-widget-right"],
                    child=Widget.Icon(icon_name="go-next-symbolic", pixel_size=16),
                    on_click=on_click_other,
                ),
            ]
        else:
            children = [
                Widget.Button(
                    css_classes=["cc-widget-left-full", "cc-widget-active" if active else ""],
                    child=left_content,
                    on_click=on_click,
                ),
            ]

        super().__init__(
            css_classes=["cc-widget"],
            children=children,
        )


class VolumeSlider(Widget.Box):
    """Volume control slider"""
    def __init__(self):
        self._icon = Widget.Button(
            css_classes=["cc-slider-icon"],
            child=Widget.Icon(
                icon_name="audio-volume-high-symbolic",
                pixel_size=16,
            ),
            on_click=self._toggle_mute,
        )

        self._slider = Widget.Scale(
            css_classes=["cc-slider-slider"],
            min=0,
            max=100,
            value=audio.speaker.volume if audio.speaker else 50,
            hexpand=True,
            on_change=lambda scale: adjust_volume(scale.value, audio),
        )

        # Bind to audio changes
        if audio.speaker:
            audio.speaker.connect("notify::volume", self._on_volume_change)
            audio.speaker.connect("notify::is-muted", self._on_mute_change)

        super().__init__(
            css_classes=["control-centre-slider"],
            spacing=8,
            children=[self._icon, self._slider],
        )

    def _toggle_mute(self, *_):
        if audio.speaker:
            audio.speaker.is_muted = not audio.speaker.is_muted

    def _on_volume_change(self, speaker, *_):
        self._slider.value = speaker.volume

    def _on_mute_change(self, speaker, *_):
        icon_name = "audio-volume-muted-symbolic" if speaker.is_muted else "audio-volume-high-symbolic"
        self._icon.child.icon_name = icon_name


class TopBox(Widget.Box):
    """Top buttons row"""
    def __init__(self, monitor: int):
        super().__init__(
            css_classes=["cc-top-box"],
            spacing=8,
            children=[
                Widget.Button(
                    css_classes=["cc-top-button"],
                    child=Widget.Icon(icon_name="emblem-system-symbolic", pixel_size=18),
                    on_click=lambda *_: None,  # Settings placeholder
                ),
                Widget.Box(hexpand=True),
                Widget.Button(
                    css_classes=["cc-top-button"],
                    child=Widget.Icon(icon_name="system-lock-screen-symbolic", pixel_size=18),
                    on_click=lambda *_: None,  # Lock placeholder
                ),
                Widget.Button(
                    css_classes=["cc-top-button"],
                    child=Widget.Icon(icon_name="system-shutdown-symbolic", pixel_size=18),
                    on_click=lambda *_: None,  # Power placeholder
                ),
            ],
        )


class MainWidgets(Widget.Box):
    """Grid of main control widgets"""
    def __init__(self, monitor: int):
        self._widgets = []
        self._grid = Widget.Box(
            orientation="vertical",
            spacing=8,
        )

        super().__init__(
            css_classes=["cc-main-widgets"],
            children=[self._grid],
        )

        self._update_widgets()

    def _update_widgets(self):
        widgets = []

        # WiFi widget
        if network.wifi:
            wifi = network.wifi
            connected = wifi.is_connected if hasattr(wifi, "is_connected") else False
            widgets.append(
                ControlCentreWidget(
                    icon="network-wireless-symbolic",
                    label="Wi-Fi",
                    secondary_label=wifi.ssid if connected and hasattr(wifi, "ssid") else "",
                    on_click=lambda *_: None,
                    on_click_other=lambda *_: None,
                    active=connected,
                )
            )

        # Bluetooth widget
        if bluetooth and not getattr(bluetooth, "is_absent", True):
            widgets.append(
                ControlCentreWidget(
                    icon="bluetooth-symbolic",
                    label="Bluetooth",
                    on_click=self._toggle_bluetooth,
                    on_click_other=lambda *_: None,
                    active=getattr(bluetooth, "is_powered", False),
                )
            )

        # Do Not Disturb widget
        widgets.append(
            ControlCentreWidget(
                icon="notifications-disabled-symbolic",
                label="Do Not Disturb",
                on_click=lambda *_: None,
                active=False,
            )
        )

        # Arrange in 2-column grid
        self._grid.children = []
        for i in range(0, len(widgets), 2):
            row = Widget.Box(spacing=8, homogeneous=True)
            row.children = widgets[i:i+2]
            self._grid.children = [*self._grid.children, row]

    def _toggle_bluetooth(self, *_):
        if bluetooth:
            bluetooth.is_powered = not getattr(bluetooth, "is_powered", False)
            self._update_widgets()


class ControlCentre(Widget.RevealerWindow):
    """Main Control Centre popup window"""
    def __init__(self, monitor: int = 0):
        self.monitor = monitor

        content = Widget.Box(
            css_classes=["control-centre"],
            orientation="vertical",
            spacing=16,
            children=[
                TopBox(monitor),
                VolumeSlider(),
                MainWidgets(monitor),
            ],
        )

        super().__init__(
            namespace=f"ignis_control_centre_{monitor}",
            monitor=monitor,
            anchor=["top", "right"],
            layer="overlay",
            kb_mode="on_demand",
            visible=False,
            transition_type="slide_down",
            transition_duration=200,
            child=Widget.Box(
                css_classes=["control-centre-container"],
                children=[
                    Widget.EventBox(
                        on_click=lambda *_: popup_manager.hide_popup(),
                        hexpand=True,
                        vexpand=True,
                    ),
                    content,
                ],
            ),
        )

        popup_manager.register_popup(f"control_centre_{monitor}", self)
