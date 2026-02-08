"""
Clock Widget - GNOME-like centered clock
"""
from ignis.widgets import Widget
from ignis.utils import Utils
from datetime import datetime


class Clock(Widget.Button):
    def __init__(self):
        self._label = Widget.Label(
            css_classes=["clock-label"],
            label=self._get_time(),
        )

        super().__init__(
            css_classes=["clock"],
            child=self._label,
        )

        # Update every second
        Utils.Poll(timeout=1000, callback=self._update_time)

    def _get_time(self) -> str:
        now = datetime.now()
        return now.strftime("%a %d %b  %H:%M:%S")

    def _update_time(self, *_):
        self._label.label = self._get_time()
        return True
