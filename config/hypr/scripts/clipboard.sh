#!/usr/bin/env bash

# Clipboard manager with image preview, pin and delete support
# Uses cliphist + wofi

PINS_FILE="$HOME/.cache/cliphist-pins"
THUMB_DIR="$HOME/.cache/cliphist-thumbs"

# Ensure directories exist
mkdir -p "$THUMB_DIR"
touch "$PINS_FILE"

# Check if item is pinned (by hash)
is_pinned() {
    grep -qxF "$1" "$PINS_FILE" 2>/dev/null
}

# Toggle pin status
toggle_pin() {
    local hash="$1"
    if is_pinned "$hash"; then
        grep -vxF "$hash" "$PINS_FILE" > "$PINS_FILE.tmp" && mv "$PINS_FILE.tmp" "$PINS_FILE"
        notify-send -t 1500 "📌 Clipboard" "Item unpinned"
    else
        echo "$hash" >> "$PINS_FILE"
        notify-send -t 1500 "📌 Clipboard" "Item pinned"
    fi
}

# Delete item from cliphist and pins
delete_item() {
    local hash="$1"
    cliphist delete <<< "$hash"
    grep -vxF "$hash" "$PINS_FILE" > "$PINS_FILE.tmp" 2>/dev/null && mv "$PINS_FILE.tmp" "$PINS_FILE"
    # Remove thumbnail if exists
    rm -f "$THUMB_DIR/$hash.png" 2>/dev/null
    notify-send -t 1500 "🗑️ Clipboard" "Item deleted"
}

# Generate thumbnail for image (returns path if successful)
get_thumb() {
    local hash="$1"
    local thumb="$THUMB_DIR/$hash.png"

    if [[ ! -f "$thumb" ]]; then
        cliphist decode <<< "$hash" 2>/dev/null | \
            convert - -resize 48x48^ -gravity center -extent 48x48 "$thumb" 2>/dev/null
    fi

    [[ -f "$thumb" ]] && echo "$thumb"
}

# Show image preview
preview_image() {
    local hash="$1"
    local tmp="/tmp/clipboard_preview_$$.png"

    cliphist decode <<< "$hash" > "$tmp" 2>/dev/null

    if [[ -f "$tmp" && -s "$tmp" ]]; then
        notify-send -i "$tmp" "🖼️ Image Preview" "Image from clipboard" -t 3000
    fi

    rm -f "$tmp" 2>/dev/null
}

# Build formatted list for wofi
build_list() {
    local pinned=()
    local regular=()

    while IFS=$'\t' read -r hash content; do
        [[ -z "$hash" ]] && continue

        local prefix=""
        local display=""
        local is_image=false

        # Check if pinned
        if is_pinned "$hash"; then
            prefix="📌 "
        fi

        # Check if image (binary data)
        if [[ "$content" == *"[[ binary data"* ]] || [[ "$content" == "[[binary"* ]]; then
            is_image=true
            display="${prefix}🖼️ [Image]"
        else
            # Truncate and clean text
            display="${prefix}$(echo "$content" | tr '\n\t' '  ' | head -c 80)"
        fi

        # Format: hash|display
        local entry="$hash|$display"

        if is_pinned "$hash"; then
            pinned+=("$entry")
        else
            regular+=("$entry")
        fi
    done < <(cliphist list)

    # Output pinned first, then regular
    printf '%s\n' "${pinned[@]}" "${regular[@]}"
}

# Show actions menu
show_actions() {
    local hash="$1"
    local is_image="$2"

    local pin_action
    if is_pinned "$hash"; then
        pin_action="📌 Unpin"
    else
        pin_action="📌 Pin"
    fi

    local options="📋 Copy to clipboard\n$pin_action\n🗑️ Delete"

    # Add preview option for images
    if [[ "$is_image" == "true" ]]; then
        options="👁️ Preview image\n$options"
    fi

    local action=$(echo -e "$options" | \
        wofi --dmenu \
             --prompt "Action" \
             --width 250 \
             --height 200 \
             --cache-file /dev/null)

    case "$action" in
        "👁️ Preview image")
            preview_image "$hash"
            show_actions "$hash" "$is_image"
            ;;
        "📋 Copy to clipboard")
            cliphist decode <<< "$hash" | wl-copy
            notify-send -t 1500 "📋 Clipboard" "Copied!"
            ;;
        "📌 Pin"|"📌 Unpin")
            toggle_pin "$hash"
            main
            ;;
        "🗑️ Delete")
            delete_item "$hash"
            main
            ;;
    esac
}

# Main function
main() {
    local list=$(build_list)

    if [[ -z "$list" ]]; then
        notify-send "📋 Clipboard" "History is empty"
        exit 0
    fi

    # Extract display text for wofi (remove hash prefix)
    local display_list=$(echo "$list" | cut -d'|' -f2)

    local selected=$(echo "$display_list" | \
        wofi --dmenu \
             --prompt " Clipboard" \
             --width 600 \
             --height 400 \
             --cache-file /dev/null)

    [[ -z "$selected" ]] && exit 0

    # Find the hash for the selected item
    local hash=""
    local is_image="false"

    while IFS='|' read -r h d; do
        if [[ "$d" == "$selected" ]]; then
            hash="$h"
            [[ "$d" == *"[Image]"* ]] && is_image="true"
            break
        fi
    done <<< "$list"

    if [[ -n "$hash" ]]; then
        show_actions "$hash" "$is_image"
    fi
}

main "$@"
