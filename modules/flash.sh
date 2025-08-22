
#!/bin/bash
# ==========================================
# Sentinal - Smooth Screen Flash Test
# ==========================================

run_flash() {
    local current=$(brightnessctl get)
    local max=$(brightnessctl max)
    local percent=$(( current * 100 / max ))

    echo "Current Brightness: $percent%"

    step=5   # smaller step = smoother animation
    delay=0.02

    # Go down to 0
    for ((b=percent; b>=0; b-=step)); do
        brightnessctl set "${b}%" -q
        sleep $delay
    done

    # Cycle up/down 3 times
    for cycle in {1..3}; do
        for ((b=0; b<=100; b+=step)); do
            brightnessctl set "${b}%" -q
            sleep $delay
        done
        for ((b=100; b>=0; b-=step)); do
            brightnessctl set "${b}%" -q
            sleep $delay
        done
    done

    # Restore original brightness
    brightnessctl set "${percent}%" -q
    echo "Restored Brightness to: $percent%"
}


