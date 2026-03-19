#!/usr/bin/env bash

# Weather script for waybar using wttr.in
# Location: Canoas, RS, Brazil
# Uses persistent cache for instant display on boot

LOCATION="Canoas"
CACHE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/weather-cache.txt"

# Try to fetch fresh weather (5 second timeout)
weather=$(curl -s -m 5 "wttr.in/$LOCATION?format=%c%t" 2>/dev/null)

if [[ -n "$weather" && ! "$weather" == *"Unknown"* ]]; then
    # Got valid weather, update cache and display
    echo "$weather" > "$CACHE_FILE"
    echo "$weather"
elif [[ -f "$CACHE_FILE" ]]; then
    # Network failed, use cached weather
    cat "$CACHE_FILE"
else
    # No network and no cache
    echo "󰼯 --"
fi
