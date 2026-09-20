#!/bin/bash
set -e

# Change to project root directory
cd "$(dirname "$0")"

# 1. Parse CLI argument if provided
PROFILE_ARG="$1"

# 2. Auto-detect profile if not explicitly specified
if [ -n "$PROFILE_ARG" ]; then
    case "$PROFILE_ARG" in
        3070|rtx3070|rtx)
            PROFILE="rtx3070"
            ;;
        jetson|orin|agx|jetson-orin)
            PROFILE="jetson"
            ;;
        *)
            echo "Unknown profile: $PROFILE_ARG"
            echo "Available profiles: 3070, jetson"
            exit 1
            ;;
    esac
elif [ -n "$COMPOSE_PROFILES" ]; then
    PROFILE="$COMPOSE_PROFILES"
else
    # Auto-detect architecture
    ARCH=$(uname -m)
    if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ] || [ -f "/etc/nv_tegra_release" ]; then
        PROFILE="jetson"
        echo "🔍 Detected ARM64 / Tegra architecture -> Activating Jetson AGX Orin profile."
    else
        PROFILE="rtx3070"
        echo "🔍 Detected x86_64 architecture -> Activating NVIDIA RTX 3070 profile."
    fi
fi

# 3. Load profile environment defaults if .env doesn't exist
if [ ! -f ".env" ]; then
    if [ "$PROFILE" = "jetson" ]; then
        echo "Copying profiles/jetson-orin.env to .env..."
        cp profiles/jetson-orin.env .env
    else
        echo "Copying profiles/rtx3070.env to .env..."
        cp profiles/rtx3070.env .env
    fi
fi

# Export COMPOSE_PROFILES for docker-compose
export COMPOSE_PROFILES="$PROFILE"

echo "=========================================================="
echo " Starting ComfyUI with profile: [ $PROFILE ]"
echo "=========================================================="

docker compose --profile "$PROFILE" up -d --remove-orphans

PORT="${PORT:-8188}"

echo ""
echo "=========================================================="
echo " ComfyUI is up and running!"
echo " Profile: $PROFILE"
echo " Web UI:  http://localhost:${PORT}"
echo " View logs: docker compose logs -f"
echo " Stop:      ./stop.sh"
echo "=========================================================="
