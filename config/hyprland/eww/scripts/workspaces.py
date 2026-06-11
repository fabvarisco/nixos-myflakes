import json, subprocess

def run(cmd):
    result = subprocess.run(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    return result.stdout.decode("utf-8").strip()

def main():
    try:
        monitors = json.loads(run("hyprctl monitors -j") or "[]")
        workspaces = json.loads(run("hyprctl workspaces -j") or "[]")
    except Exception:
        monitors, workspaces = [], []

    occupied = {ws["id"] for ws in workspaces}
    focused_active = next(
        (m["activeWorkspace"]["id"] for m in monitors if m.get("focused")),
        monitors[0]["activeWorkspace"]["id"] if monitors else 1
    )

    # Group workspaces by monitor for the separator
    monitor_map = {}
    for m in monitors:
        monitor_map[m["id"]] = m["activeWorkspace"]["id"]

    ws_per_monitor = {m["id"]: [] for m in monitors}
    for ws in workspaces:
        mid = ws.get("monitorID", 0)
        if mid in ws_per_monitor:
            ws_per_monitor[mid].append(ws["id"])

    if not monitors:
        widget_str = "(box :space-evenly false :spacing 0 :vexpand true :hexpand false "
        for ws_id in range(1, 6):
            widget_str += f"(eventbox :cursor \"pointer\" :onclick \"hyprctl dispatch workspace {ws_id}\" (label :class \"empty-ws\" :text \"{ws_id}\"))"
        widget_str += ")"
        print(widget_str)
        return

    # Always show at least workspaces 1-5 on the first monitor
    first_monitor_id = monitors[0]["id"]
    existing = set(ws_per_monitor.get(first_monitor_id, []))
    shown = sorted(existing | set(range(1, 6)))
    ws_per_monitor[first_monitor_id] = shown

    widget_str = "(box :space-evenly false :spacing 0 :vexpand true :hexpand false "

    for i, m in enumerate(monitors):
        mid = m["id"]
        active = monitor_map.get(mid, -1)
        for ws_id in sorted(ws_per_monitor.get(mid, [])):
            if ws_id == focused_active:
                cls = "active-monitor-ws"
            elif ws_id == active:
                cls = "occupied-monitor-ws"
            elif ws_id in occupied:
                cls = "occupied-ws"
            else:
                cls = "empty-ws"
            widget_str += f"(eventbox :cursor \"pointer\" :onclick \"hyprctl dispatch workspace {ws_id}\" (label :class \"{cls}\" :text \"{ws_id}\"))"
        if i < len(monitors) - 1:
            widget_str += "(box :class \"ws-separator\")"

    widget_str += ")"
    print(widget_str)

main()
