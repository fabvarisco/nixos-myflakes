"""
Utility functions for Ignis configuration
"""
import os
import subprocess
from ignis.app import IgnisApp
from ignis.services.hyprland import HyprlandService

app = IgnisApp.get_default()
hyprland = HyprlandService.get_default()

CONFIG_DIR = os.path.dirname(os.path.abspath(__file__))


def shell(cmd: str, background: bool = False) -> str | None:
    """Execute a shell command"""
    try:
        if background:
            subprocess.Popen(cmd, shell=True)
            return None
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        return result.stdout.strip()
    except Exception:
        return None


def has_command(cmd: str) -> bool:
    """Check if a command exists"""
    return shell(f"which {cmd}") is not None


def format_time(seconds: int) -> str:
    """Format seconds to human-readable time"""
    hours = seconds // 3600
    minutes = (seconds % 3600) // 60
    secs = seconds % 60

    if hours > 0:
        return f"{hours}:{minutes:02d}:{secs:02d}"
    return f"{minutes}:{secs:02d}"


def adjust_volume(volume: float, audio_service) -> None:
    """Adjust volume handling mute state"""
    speaker = audio_service.speaker
    if speaker:
        if speaker.is_muted:
            speaker.is_muted = False
        speaker.volume = max(0, min(100, volume))


class PopupManager:
    """Singleton manager for popups across monitors"""
    _instance = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
            cls._instance._popups = {}
            cls._instance._active_popup = None
            cls._instance.animation_speed = 200
        return cls._instance

    def register_popup(self, name: str, popup):
        self._popups[name] = popup

    def show_popup(self, name: str):
        if self._active_popup and self._active_popup != name:
            self.hide_popup(self._active_popup)
        if name in self._popups:
            self._popups[name].visible = True
            self._active_popup = name

    def hide_popup(self, name: str = None):
        if name is None:
            name = self._active_popup
        if name and name in self._popups:
            self._popups[name].visible = False
        if self._active_popup == name:
            self._active_popup = None

    def toggle_popup(self, name: str):
        if self._active_popup == name:
            self.hide_popup(name)
        else:
            self.show_popup(name)

    def clear_popups(self):
        for name in self._popups:
            self._popups[name].visible = False
        self._active_popup = None


popup_manager = PopupManager()
