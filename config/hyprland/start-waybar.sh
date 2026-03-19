#!/usr/bin/env bash

# Waybar startup script with pywal integration
# Uses default colors if pywal hasn't run yet, starts immediately

CACHE_DIR="$HOME/.cache/wal"

# Kill any existing waybar instances first
killall -q waybar 2>/dev/null
sleep 0.2

# Generate complete CSS files (GTK CSS doesn't support @import)
generate_css() {
    local colors_file="$CACHE_DIR/colors-waybar.css"
    local waybar_base="$HOME/.config/waybar/style.css"

    mkdir -p "$CACHE_DIR"

    # If pywal colors don't exist yet, create default colors
    if [ ! -f "$colors_file" ]; then
        cat > "$colors_file" << 'EOF'
/* Waybar colors - Default fallback */
@define-color background #1a1a2e;
@define-color foreground #eaeaea;
@define-color color0 #1a1a2e;
@define-color color1 #ff6b6b;
@define-color color2 #4ecdc4;
@define-color color3 #ffe66d;
@define-color color4 #6c5ce7;
@define-color color5 #fd79a8;
@define-color color6 #74b9ff;
@define-color color7 #dfe6e9;
@define-color color8 #636e72;
EOF
    fi

    if [ -f "$colors_file" ] && [ -f "$waybar_base" ]; then
        # Generate waybar CSS (colors + styles without @import line)
        cat "$colors_file" > "$CACHE_DIR/waybar-style.css"
        tail -n +2 "$waybar_base" >> "$CACHE_DIR/waybar-style.css"
    fi
}

generate_css

# Start waybar with generated CSS if it exists, otherwise use default
if [ -f "$CACHE_DIR/waybar-style.css" ]; then
    waybar -s "$CACHE_DIR/waybar-style.css" &
else
    waybar &
fi
disown
