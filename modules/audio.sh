# ==========================================
# Audio Functions for Sentinal
# ==========================================

stop_audio() {
    if [[ ${AUDIO_PID:-0} -ne 0 ]]; then
        kill $AUDIO_PID 2>/dev/null || true
        wait $AUDIO_PID 2>/dev/null || true
        AUDIO_PID=0
    fi
    pkill -f "$AUDIO_PLAYER" 2>/dev/null || true
}

play_audio() {
    local audio="$1"
    local current_time
    current_time=$(date +%s)

    if (( current_time - LAST_AUDIO_TIME >= AUDIO_DELAY )); then
        stop_audio
        log "🔊 Playing audio ($audio)"
        $AUDIO_PLAYER "$audio" &>/dev/null &
        AUDIO_PID=$!
        LAST_AUDIO_TIME=$current_time
    fi
}

