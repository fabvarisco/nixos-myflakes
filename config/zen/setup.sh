#!/usr/bin/env bash
# Initial setup script for Zen Browser with PywalZen theme

ZEN_DIR="$HOME/.zen"
ZEN_CONFIG="$HOME/.config/zen"
STARTPAGE_SRC="$(dirname "$0")/startpage"
STARTPAGE_DST="$HOME/.local/share/zen-startpage"

echo "Setting up Zen Browser..."

# Setup startpage
if [ -d "$STARTPAGE_SRC" ]; then
    mkdir -p "$STARTPAGE_DST"
    cp -r "$STARTPAGE_SRC"/* "$STARTPAGE_DST/"
    echo "Startpage installed to $STARTPAGE_DST"
fi

# Find and configure all Zen profiles
for profile in "$ZEN_DIR"/*; do
    if [ -d "$profile" ] && [[ "$(basename "$profile")" != "Profile Groups" ]]; then
        echo "Configuring profile: $(basename "$profile")"

        mkdir -p "$profile/chrome"

        # Copy userChrome.css (remove existing to handle read-only files)
        if [ -f "$ZEN_CONFIG/userChrome.css" ]; then
            rm -f "$profile/chrome/userChrome.css" 2>/dev/null
            cp "$ZEN_CONFIG/userChrome.css" "$profile/chrome/userChrome.css"
        fi

        # Copy user.js
        if [ -f "$ZEN_CONFIG/user.js" ]; then
            rm -f "$profile/user.js" 2>/dev/null
            cp "$ZEN_CONFIG/user.js" "$profile/user.js"
        fi
    fi
done

echo ""
echo "Setup complete!"
echo ""
echo "Next steps:"
echo "1. Install the Pywalfox extension in Zen Browser:"
echo "   https://addons.mozilla.org/firefox/addon/pywalfox/"
echo ""
echo "2. After installing, run: pywalfox update"
echo ""
echo "3. Change your wallpaper to apply colors"
echo ""
