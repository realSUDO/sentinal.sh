# ==========================================
# Notifications for Sentinal
# ==========================================

send_notification() {
    local title="$1"
    local message="$2"
    local urgency="${3:-normal}"
    notify-send -u "$urgency" "🔋 Sentinal: $title" "$message"
}

