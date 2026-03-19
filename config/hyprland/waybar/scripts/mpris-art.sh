#!/usr/bin/env bash

COVER_PATH="/tmp/mpris-cover.jpg"
CACHE_URL="/tmp/mpris-cover-url.txt"

# Get art URL from playerctl
art_url=$(playerctl metadata mpris:artUrl 2>/dev/null)

if [[ -z "$art_url" ]]; then
    # No media playing, remove old cover
    rm -f "$COVER_PATH" "$CACHE_URL"
    exit 0
fi

# Only download if URL changed (avoid re-downloading same image)
cached_url=""
[[ -f "$CACHE_URL" ]] && cached_url=$(cat "$CACHE_URL")

if [[ "$art_url" != "$cached_url" ]]; then
    # Handle file:// URLs (local files)
    if [[ "$art_url" == file://* ]]; then
        local_path="${art_url#file://}"
        cp "$local_path" "$COVER_PATH" 2>/dev/null
    # Handle http(s):// URLs (YouTube, Spotify web, etc)
    elif [[ "$art_url" == http* ]]; then
        curl -s -m 3 -L "$art_url" -o "$COVER_PATH" 2>/dev/null
    fi
    echo "$art_url" > "$CACHE_URL"
fi

# Output path if cover exists
if [[ -f "$COVER_PATH" ]]; then
    title=$(playerctl metadata title 2>/dev/null)
    artist=$(playerctl metadata artist 2>/dev/null)
    album=$(playerctl metadata album 2>/dev/null)
    player=$(playerctl metadata --format '{{playerName}}' 2>/dev/null)
    status=$(playerctl status 2>/dev/null)

    # Format position/length if available
    position=$(playerctl metadata --format '{{duration(position)}}' 2>/dev/null)
    length=$(playerctl metadata --format '{{duration(mpris:length)}}' 2>/dev/null)

    # Build tooltip
    tooltip="󰎈 ${title:-Unknown}"
    [[ -n "$artist" ]] && tooltip+="\n ${artist}"
    [[ -n "$album" ]] && tooltip+="\n󰀥 ${album}"
    [[ -n "$position" && -n "$length" ]] && tooltip+="\n󰁫 ${position} / ${length}"
    tooltip+="\n ${player^} (${status})"

    # Output: path\ntooltip
    echo "$COVER_PATH"
    echo -e "$tooltip"
fi
