#!/bin/bash
# ==========================================
# Sentinal - Battery Monitor & Alerts
# Entrypoint script
# ==========================================

set -u
set -o pipefail

echo "DEBUG: starting sentinal..."

# === Load Modules ===
BASE_DIR="$(dirname "$(realpath "$0")")"
source "$BASE_DIR/modules/config.sh"
source "$BASE_DIR/modules/log.sh"
source "$BASE_DIR/modules/battery.sh"
source "$BASE_DIR/modules/audio.sh"
source "$BASE_DIR/modules/notify.sh"
source "$BASE_DIR/modules/flash.sh"

# === State Vars ===
LOCKED_LOW=0
LOCKED_FULL=0
AUDIO_PID=0
LAST_AUDIO_TIME=0

cleanup() {
    log "🛑 Cleaning up..."
    stop_audio
    exit 0
}
trap cleanup SIGINT SIGTERM

on_error() { log "❌ Runtime error encountered (continuing)."; }
trap on_error ERR

# === Monitor Loop ===
monitor_loop() {
    local sleep_interval=3
    log "🟢 Sentinal monitor started"

    while true; do
        get_battery_info
        log "📊 Battery check → ${BATTERY_PERCENT}% | Status: ${CHARGING_STATUS}"

        # Dynamic check interval
        if should_check_slowly; then
            sleep_interval=10
        else
            sleep_interval=3
        fi

		# ---- LOW BATTERY ----
if [[ "$BATTERY_PERCENT" -le "$LOW_THRESHOLD" && "$CHARGING_STATUS" == "Discharging" ]]; then
    if [[ $LOCKED_LOW -eq 0 ]]; then
        log "⚠️ Low battery alert triggered!"
        run_flash &
        send_notification "Low Battery" "Battery at ${BATTERY_PERCENT}%. Plug in charger!" "critical" &
        LOCKED_LOW=1
    fi
    play_audio "$LOW_AUDIO"   # always try, cooldown prevents spam
else
    if [[ $LOCKED_LOW -eq 1 ]]; then
        log "✅ Low battery cleared."
        LOCKED_LOW=0
        stop_audio
    fi
fi

# ---- FULL BATTERY ----
if [[ "$BATTERY_PERCENT" -ge "$FULL_THRESHOLD" && "$CHARGING_STATUS" == "Charging" ]]; then
    if [[ $LOCKED_FULL -eq 0 ]]; then
        log "⚡ Full charge alert triggered!"
        run_flash &
        send_notification "Full Battery" "Battery at ${BATTERY_PERCENT}%. Unplug charger." "normal" &
        LOCKED_FULL=1
    fi
    play_audio "$FULL_AUDIO"
else
    if [[ $LOCKED_FULL -eq 1 ]]; then
        log "✅ Full charge cleared."
        LOCKED_FULL=0
        stop_audio
    fi
fi
        sleep "$sleep_interval" || true
    done
}

monitor_loop

