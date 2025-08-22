#!/bin/bash
# ==========================================
# Sentinal - Interactive Config Tool
# ==========================================

BASE_DIR="$(dirname "$(realpath "$0")")/.."   # project root
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/sentinal"
CONFIG_FILE="$CONFIG_DIR/sentinal.conf"
USER_SOUND_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/sentinal/sounds"
DEFAULT_SOUND_DIR="$BASE_DIR/sounds"

# Ensure dirs exist
mkdir -p "$CONFIG_DIR" "$USER_SOUND_DIR"

# Copy default sounds if missing
if compgen -G "$USER_SOUND_DIR/*.wav" > /dev/null; then
    echo "🎵 Using existing sounds in $USER_SOUND_DIR"
else
    echo "📂 Copying default sounds from $DEFAULT_SOUND_DIR → $USER_SOUND_DIR"
    cp -n "$DEFAULT_SOUND_DIR"/*.wav "$USER_SOUND_DIR"/ 2>/dev/null || \
        echo "⚠️ No default sounds found in $DEFAULT_SOUND_DIR"
fi

# Use user dir for sound selection
SOUND_DIR="$USER_SOUND_DIR"

echo "⚙️  Sentinal Configuration"
echo "============================"
echo ""

# --- Thresholds ---
read -rp "Enter LOW battery threshold [%] (default 20): " low
read -rp "Enter FULL battery threshold [%] (default 90): " full
LOW_THRESHOLD=${low:-20}
FULL_THRESHOLD=${full:-90}

# --- Sound Selection ---
echo ""
echo "🎵 Available sounds in: $SOUND_DIR"
ls "$SOUND_DIR" 2>/dev/null || echo "⚠️ No sounds found (add .wav files here)"

read -rp "Select LOW battery sound filename (default: low.wav): " low_s
read -rp "Select FULL battery sound filename (default: full.wav): " full_s
LOW_AUDIO="$SOUND_DIR/${low_s:-low.wav}"
FULL_AUDIO="$SOUND_DIR/${full_s:-full.wav}"

# --- Locker ---
read -rp "Enter screen locker command (default hyprlock): " locker
LOCKER=${locker:-hyprlock}

# --- Audio Player ---
read -rp "Enter audio player (paplay/aplay) [default paplay]: " player
AUDIO_PLAYER=${player:-paplay}

# --- Audio Delay ---
read -rp "Delay between repeated alerts [seconds] (default 15): " delay
AUDIO_DELAY=${delay:-15}

# --- Write Config ---
cat > "$CONFIG_FILE" <<EOF
# ==========================================
# Sentinal User Configuration (auto-generated)
# ==========================================

LOW_THRESHOLD=$LOW_THRESHOLD
FULL_THRESHOLD=$FULL_THRESHOLD

LOW_AUDIO="$LOW_AUDIO"
FULL_AUDIO="$FULL_AUDIO"

LOCKER="$LOCKER"
AUDIO_PLAYER="$AUDIO_PLAYER"
AUDIO_DELAY=$AUDIO_DELAY
EOF

echo ""
echo "✅ Configuration saved to $CONFIG_FILE"
echo "You can restart Sentinal to apply changes:"
echo "   systemctl --user restart sentinal.service"

