# ==========================================
# Battery Functions for Sentinal (robust)
# ==========================================

get_battery_info() {
    local info
    info=$(acpi -b 2>/dev/null)

    if [[ -z "$info" ]]; then
        BATTERY_PERCENT=0
        CHARGING_STATUS="Unknown"
        log "⚠️ No battery info detected"
        return
    fi

    # Extract percent
    BATTERY_PERCENT=$(echo "$info" | grep -oP '[0-9]+(?=%)' | head -n1)

    # Extract status safely
    if echo "$info" | grep -q "Charging"; then
        CHARGING_STATUS="Charging"
    elif echo "$info" | grep -q "Discharging"; then
        CHARGING_STATUS="Discharging"
    elif echo "$info" | grep -q "Full"; then
        CHARGING_STATUS="Full"
    elif echo "$info" | grep -q "Not charging"; then
        CHARGING_STATUS="Not charging"
    else
        CHARGING_STATUS="Unknown"
    fi

    # Special case: "Not charging" but safe percent
    if [[ "$CHARGING_STATUS" == "Not charging" && "$BATTERY_PERCENT" -gt $LOW_THRESHOLD ]]; then
        CHARGING_STATUS="Charging"
    fi

    log "DEBUG → Battery=${BATTERY_PERCENT}% Status=${CHARGING_STATUS}"
}

should_check_slowly() {
    [[ ("$BATTERY_PERCENT" -le $LOW_THRESHOLD && "$CHARGING_STATUS" == "Discharging") || \
       ("$BATTERY_PERCENT" -ge $FULL_THRESHOLD && "$CHARGING_STATUS" == "Charging") ]]
}

