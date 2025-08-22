# ==========================================
# Logging & Cleanup for Sentinal
# ==========================================

log() {
    echo "[LOG $(date '+%H:%M:%S')] $1"
}

cleanup() {
    log "🛑 Cleaning up..."
    [[ ${AUDIO_PID:-0} -ne 0 ]] && kill $AUDIO_PID 2>/dev/null || true
    [[ ${LOCKER_PID:-0} -ne 0 ]] && kill $LOCKER_PID 2>/dev/null || true
    pkill -f "$AUDIO_PLAYER" 2>/dev/null || true
    exit 0
}

