# ==========================================
# Default Config for Sentinal
# ==========================================

# Thresholds
LOW_THRESHOLD=15
FULL_THRESHOLD=98

# Default Sounds (XDG path, can be overridden in ~/.config/sentinal/sentinal.conf)
LOW_AUDIO="${XDG_DATA_HOME:-$HOME/.local/share}/sentinal/sounds/low.wav"
FULL_AUDIO="${XDG_DATA_HOME:-$HOME/.local/share}/sentinal/sounds/full.wav"

# Locker & Audio
LOCKER="hyprlock"
AUDIO_PLAYER="paplay"   # paplay works with .wav/.ogg (PulseAudio/PipeWire)
AUDIO_DELAY=10

# Load user config if present
USER_CONF="${XDG_CONFIG_HOME:-$HOME/.config}/sentinal/sentinal.conf"
[[ -f "$USER_CONF" ]] && source "$USER_CONF"

