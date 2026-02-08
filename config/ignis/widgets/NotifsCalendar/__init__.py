"""
Notifications & Calendar Widget - GNOME-like notification panel with calendar
"""
from ignis.widgets import Widget
from ignis.utils import Utils
from ignis.services.notifications import NotificationService
from datetime import datetime
from calendar import monthrange, weekday

from util import popup_manager

notifications = NotificationService.get_default()


def get_month_days(year: int, month: int) -> int:
    """Get number of days in a month"""
    return monthrange(year, month)[1]


def starting_dow_for_month(year: int, month: int) -> int:
    """Get the weekday of the first day of the month (0=Monday)"""
    return weekday(year, month, 1)


class CalendarGrid(Widget.Box):
    """Calendar grid showing days of the month"""
    def __init__(self, year: int, month: int):
        self.year = year
        self.month = month

        super().__init__(
            css_classes=["calendar-grid"],
            orientation="vertical",
            spacing=4,
        )

        self._build_grid()

    def _build_grid(self):
        today = datetime.now()
        days_in_month = get_month_days(self.year, self.month)
        start_dow = starting_dow_for_month(self.year, self.month)

        # Header row (day names)
        header = Widget.Box(css_classes=["calendar-header"], spacing=4, homogeneous=True)
        for day_name in ["M", "T", "W", "T", "F", "S", "S"]:
            header.children = [*header.children, Widget.Label(
                label=day_name,
                css_classes=["calendar-day-name", "calendar-weekend" if day_name == "S" else ""],
            )]
        self.children = [header]

        # Day grid
        day = 1
        prev_month = self.month - 1 if self.month > 1 else 12
        prev_year = self.year if self.month > 1 else self.year - 1
        prev_month_days = get_month_days(prev_year, prev_month)

        for week in range(6):
            if day > days_in_month:
                break

            row = Widget.Box(css_classes=["calendar-week"], spacing=4, homogeneous=True)
            for dow in range(7):
                if week == 0 and dow < start_dow:
                    # Previous month days
                    prev_day = prev_month_days - start_dow + dow + 1
                    row.children = [*row.children, Widget.Label(
                        label=str(prev_day),
                        css_classes=["calendar-day", "calendar-other-month"],
                    )]
                elif day > days_in_month:
                    # Next month days
                    next_day = day - days_in_month
                    row.children = [*row.children, Widget.Label(
                        label=str(next_day),
                        css_classes=["calendar-day", "calendar-other-month"],
                    )]
                    day += 1
                else:
                    # Current month days
                    is_today = (
                        day == today.day and
                        self.month == today.month and
                        self.year == today.year
                    )
                    is_weekend = dow >= 5

                    css = ["calendar-day"]
                    if is_today:
                        css.append("calendar-today")
                    if is_weekend:
                        css.append("calendar-weekend")

                    row.children = [*row.children, Widget.Label(
                        label=str(day),
                        css_classes=css,
                    )]
                    day += 1

            self.children = [*self.children, row]


class Calendar(Widget.Box):
    """Full calendar widget with navigation"""
    def __init__(self):
        self._now = datetime.now()
        self._current_year = self._now.year
        self._current_month = self._now.month

        self._date_label = Widget.Label(
            css_classes=["calendar-date-label"],
            label=self._get_date_string(),
        )

        self._month_label = Widget.Label(
            css_classes=["calendar-month-label"],
            label=self._get_month_string(),
        )

        self._grid_container = Widget.Box()
        self._update_grid()

        # Navigation
        nav = Widget.Box(
            css_classes=["calendar-nav"],
            spacing=8,
            children=[
                Widget.Button(
                    css_classes=["calendar-nav-btn"],
                    child=Widget.Icon(icon_name="go-previous-symbolic", pixel_size=16),
                    on_click=self._prev_month,
                ),
                self._month_label,
                Widget.Button(
                    css_classes=["calendar-nav-btn"],
                    child=Widget.Icon(icon_name="go-next-symbolic", pixel_size=16),
                    on_click=self._next_month,
                ),
            ],
        )

        super().__init__(
            css_classes=["calendar"],
            orientation="vertical",
            spacing=12,
            children=[
                # Day and full date at top
                Widget.Box(
                    orientation="vertical",
                    children=[
                        Widget.Label(
                            css_classes=["calendar-weekday"],
                            label=self._now.strftime("%A"),
                            halign="start",
                        ),
                        self._date_label,
                    ],
                ),
                nav,
                self._grid_container,
            ],
        )

        # Update time every second
        Utils.Poll(timeout=1000, callback=self._update_time)

    def _get_date_string(self) -> str:
        return self._now.strftime("%d %B %Y")

    def _get_month_string(self) -> str:
        month_names = [
            "January", "February", "March", "April", "May", "June",
            "July", "August", "September", "October", "November", "December"
        ]
        name = month_names[self._current_month - 1]
        if self._current_year != self._now.year:
            return f"{name} {self._current_year}"
        return name

    def _update_grid(self):
        self._grid_container.children = [
            CalendarGrid(self._current_year, self._current_month)
        ]

    def _prev_month(self, *_):
        if self._current_month == 1:
            self._current_month = 12
            self._current_year -= 1
        else:
            self._current_month -= 1
        self._month_label.label = self._get_month_string()
        self._update_grid()

    def _next_month(self, *_):
        if self._current_month == 12:
            self._current_month = 1
            self._current_year += 1
        else:
            self._current_month += 1
        self._month_label.label = self._get_month_string()
        self._update_grid()

    def _update_time(self, *_):
        self._now = datetime.now()
        self._date_label.label = self._get_date_string()
        return True


class NotificationItem(Widget.Box):
    """Single notification item"""
    def __init__(self, notification):
        self._notification = notification

        icon = Widget.Box(css_classes=["notif-icon"])
        if notification.icon:
            icon.children = [Widget.Icon(icon_name=notification.icon, pixel_size=32)]

        content = Widget.Box(
            orientation="vertical",
            hexpand=True,
            children=[
                Widget.Box(
                    children=[
                        Widget.Label(
                            label=notification.app_name or "Notification",
                            css_classes=["notif-app-name"],
                            halign="start",
                        ),
                        Widget.Label(
                            label=notification.time.strftime("%H:%M") if hasattr(notification, "time") else "",
                            css_classes=["notif-time"],
                            halign="end",
                            hexpand=True,
                        ),
                    ],
                ),
                Widget.Label(
                    label=notification.summary or "",
                    css_classes=["notif-summary"],
                    halign="start",
                    wrap=True,
                ),
                Widget.Label(
                    label=notification.body or "",
                    css_classes=["notif-body"],
                    halign="start",
                    wrap=True,
                    visible=bool(notification.body),
                ),
            ],
        )

        dismiss_btn = Widget.Button(
            css_classes=["notif-dismiss"],
            child=Widget.Icon(icon_name="window-close-symbolic", pixel_size=14),
            on_click=lambda *_: notification.dismiss(),
        )

        super().__init__(
            css_classes=["notification-item"],
            spacing=12,
            children=[icon, content, dismiss_btn],
        )


class NotificationsList(Widget.Box):
    """List of notifications"""
    def __init__(self):
        self._list = Widget.Box(
            css_classes=["notifications-list"],
            orientation="vertical",
            spacing=8,
        )

        self._empty = Widget.Label(
            label="No notifications",
            css_classes=["notifications-empty"],
        )

        super().__init__(
            css_classes=["notifications-container"],
            orientation="vertical",
            vexpand=True,
            children=[
                Widget.Box(
                    children=[
                        Widget.Label(label="Notifications", css_classes=["notifications-title"], halign="start"),
                        Widget.Box(hexpand=True),
                        Widget.Button(
                            css_classes=["notifications-clear"],
                            child=Widget.Label(label="Clear"),
                            on_click=self._clear_all,
                        ),
                    ],
                ),
                Widget.ScrolledWindow(
                    css_classes=["notifications-scroll"],
                    vexpand=True,
                    child=self._list,
                ),
            ],
        )

        self._update_notifications()
        notifications.connect("notified", lambda *_: self._update_notifications())
        notifications.connect("closed", lambda *_: self._update_notifications())

    def _update_notifications(self):
        notifs = list(notifications.notifications)
        if notifs:
            self._list.children = [NotificationItem(n) for n in reversed(notifs)]
        else:
            self._list.children = [self._empty]

    def _clear_all(self, *_):
        for n in list(notifications.notifications):
            n.dismiss()


class NotifsCalendar(Widget.RevealerWindow):
    """Main Notifications & Calendar popup window"""
    def __init__(self, monitor: int = 0):
        self.monitor = monitor

        content = Widget.Box(
            css_classes=["notifs-calendar"],
            spacing=16,
            children=[
                NotificationsList(),
                Calendar(),
            ],
        )

        super().__init__(
            namespace=f"ignis_notifs_calendar_{monitor}",
            monitor=monitor,
            anchor=["top"],
            layer="overlay",
            kb_mode="on_demand",
            visible=False,
            transition_type="slide_down",
            transition_duration=200,
            child=Widget.Box(
                css_classes=["notifs-calendar-container"],
                orientation="vertical",
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

        popup_manager.register_popup(f"notifs_calendar_{monitor}", self)
