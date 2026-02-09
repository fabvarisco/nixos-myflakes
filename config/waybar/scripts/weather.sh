#!/usr/bin/env bash

# Weather script for waybar using wttr.in
# Location: Canoas, RS, Brazil

LOCATION="Canoas"

weather=$(curl -s "wttr.in/$LOCATION?format=%c%t" 2>/dev/null)

if [ -z "$weather" ] || [[ "$weather" == *"Unknown"* ]]; then
    echo "󰼯 --"
else
    echo "$weather"
fi
