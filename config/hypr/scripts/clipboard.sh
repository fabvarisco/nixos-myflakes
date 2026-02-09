#!/usr/bin/env bash

# Clipboard manager with image preview, pin and delete support
# Uses cliphist + wofi

PINS_FILE="$HOME/.cache/cliphist-pins"
THUMB_DIR="$HOME/.cache/cliphist-thumbs"

# Ensure directories exist
mkdir -p "$THUMB_DIR"
touch "$PINS_FILE"

# Get a hash for an entry (first field)
get_id() {
    echo "$1" | cut -f1
}

# Check if item is pinned (by id)
is_pinned() {
    local id=$(get_id "$1")
    grep -qxF "$id" "$PINS_FILE" 2>/dev/null
}

# Toggle pin status
toggle_pin() {
    local id=$(get_id "$1")
    if grep -qxF "$id" "$PINS_FILE" 2>/dev/null; then
        grep -vxF "$id" "$PINS_FILE" > "$PINS_FILE.tmp" && mv "$PINS_FILE.tmp" "$PINS_FILE"
        notify-send -t 1500 "Clipboard" "Item unpinned"
    else
        echo "$id" >> "$PINS_FILE"
        notify-send -t 1500 "Clipboard" "Item pinned"
    fi
}

# Delete item from cliphist and pins
delete_item() {
    local entry="$1"
    local id=$(get_id "$entry")

    echo "$entry" | cliphist delete
    grep -vxF "$id" "$PINS_FILE" > "$PINS_FILE.tmp" 2>/dev/null && mv "$PINS_FILE.tmp" "$PINS_FILE"

    # Remove thumbnail if exists
    rm -f "$THUMB_DIR/$id.png" 2>/dev/null
    notify-send -t 1500 "Clipboard" "Item deleted"
}

# Check if entry is an image
is_image_entry() {
    echo "$1" | grep -qE '\[\[.*binary.*\]\]'
}

# Show image preview using imv or feh
preview_image() {
    local entry="$1"
    local tmp="/tmp/clipboard_preview_$$.png"

    echo "$entry" | cliphist decode > "$tmp" 2>/dev/null

    if [[ -f "$tmp" && -s "$tmp" ]]; then
        # Try imv first, then feh, then notify-send as fallback
        if command -v imv &>/dev/null; then
            imv -s none "$tmp" &
            sleep 3
            pkill -f "imv.*$tmp" 2>/dev/null
        elif command -v feh &>/dev/null; then
            feh --scale-down --auto-zoom "$tmp" &
            sleep 3
            pkill -f "feh.*$tmp" 2>/dev/null
        else
            # Fallback to notification with image
            notify-send -i "$tmp" "Image Preview" "Image from clipboard" -t 5000
        fi
    else
        notify-send -t 2000 "Clipboard" "Failed to preview image"
    fi

    rm -f "$tmp" 2>/dev/null
}

# Copy item to clipboard
copy_item() {
    local entry="$1"
    echo "$entry" | cliphist decode | wl-copy
    notify-send -t 1500 "Clipboard" "Copied!"
}

# Show actions menu for an item
show_actions() {
    local entry="$1"
    local is_img="$2"

    local id=$(get_id "$entry")

    local pin_label
    if grep -qxF "$id" "$PINS_FILE" 2>/dev/null; then
        pin_label="Unpin"
    else
        pin_label="Pin"
    fi

    local options="Copy\n$pin_label\nDelete"

    if [[ "$is_img" == "true" ]]; then
        options="Preview\n$options"
    fi

    local action=$(echo -e "$options" | \
        wofi --dmenu \
             --prompt "Action" \
             --width 200 \
             --height 180 \
             --cache-file /dev/null)

    case "$action" in
        "Preview")
            preview_image "$entry"
            show_actions "$entry" "$is_img"
            ;;
        "Copy")
            copy_item "$entry"
            ;;
        "Pin"|"Unpin")
            toggle_pin "$entry"
            main
            ;;
        "Delete")
            delete_item "$entry"
            main
            ;;
    esac
}

# Main function
main() {
    # Get all entries from cliphist
    local entries=()
    local display_lines=()
    local pinned_entries=()
    local pinned_display=()
    local regular_entries=()
    local regular_display=()

    while IFS= read -r line; do
        [[ -z "$line" ]] && continue

        local id=$(get_id "$line")
        local content=$(echo "$line" | cut -f2-)
        local prefix=""
        local display=""

        # Check if pinned
        if grep -qxF "$id" "$PINS_FILE" 2>/dev/null; then
            prefix="[PIN] "
        fi

        # Check if image
        if echo "$line" | grep -qE '\[\[.*binary.*\]\]'; then
            display="${prefix}[Image]"
        else
            # Truncate and clean text for display
            display="${prefix}$(echo "$content" | tr '\n\t\r' '   ' | head -c 80)"
        fi

        if [[ -n "$prefix" ]]; then
            pinned_entries+=("$line")
            pinned_display+=("$display")
        else
            regular_entries+=("$line")
            regular_display+=("$display")
        fi
    done < <(cliphist list)

    # Combine pinned first, then regular
    entries=("${pinned_entries[@]}" "${regular_entries[@]}")
    display_lines=("${pinned_display[@]}" "${regular_display[@]}")

    if [[ ${#entries[@]} -eq 0 ]]; then
        notify-send "Clipboard" "History is empty"
        exit 0
    fi

    # Show wofi menu
    local selected=$(printf '%s\n' "${display_lines[@]}" | \
        wofi --dmenu \
             --prompt "Clipboard" \
             --width 600 \
             --height 400 \
             --cache-file /dev/null)

    [[ -z "$selected" ]] && exit 0

    # Find the matching entry
    local idx=0
    for i in "${!display_lines[@]}"; do
        if [[ "${display_lines[$i]}" == "$selected" ]]; then
            idx=$i
            break
        fi
    done

    local chosen_entry="${entries[$idx]}"
    local is_img="false"

    if echo "$chosen_entry" | grep -qE '\[\[.*binary.*\]\]'; then
        is_img="true"
    fi

    show_actions "$chosen_entry" "$is_img"
}

main "$@"
