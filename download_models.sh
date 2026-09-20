#!/bin/bash
set -e

# Load .env if present
if [ -f ".env" ]; then
    set -a
    . ./.env
    set +a
fi

TARGET_DIR="${STORAGE_DIR:-./data}/models"

echo "=========================================================="
echo " Downloading Qwen-Image-2.1 models for ComfyUI"
echo " Destination: $TARGET_DIR"
echo "=========================================================="

mkdir -p "$TARGET_DIR/diffusion_models" "$TARGET_DIR/text_encoders" "$TARGET_DIR/vae"

FILES=(
    "diffusion_models/qwen_image_2.1_int8_convrot.safetensors"
    "text_encoders/qwen3vl_8b_int8_convrot.safetensors"
    "vae/qwen_image_2.1_vae_bf16.safetensors"
)

NEED_DOWNLOAD=()
for f in "${FILES[@]}"; do
    if [ ! -f "$TARGET_DIR/$f" ]; then
        NEED_DOWNLOAD+=("$f")
    else
        echo "✓ Already present: $f"
    fi
done

if [ ${#NEED_DOWNLOAD[@]} -eq 0 ]; then
    echo "All models are already downloaded and ready!"
    exit 0
fi

echo "Downloading missing files: ${NEED_DOWNLOAD[*]}"

# Method 1: Host 'hf' CLI
if command -v hf >/dev/null 2>&1; then
    echo "Using host 'hf' CLI..."
    hf download Comfy-Org/Qwen-Image-2.1 "${NEED_DOWNLOAD[@]}" --local-dir "$TARGET_DIR"
# Method 2: Host python huggingface_hub
elif python3 -c "import huggingface_hub" >/dev/null 2>&1; then
    echo "Using host python huggingface_hub..."
    for f in "${NEED_DOWNLOAD[@]}"; do
        python3 -c "from huggingface_hub import hf_hub_download; hf_hub_download(repo_id='Comfy-Org/Qwen-Image-2.1', filename='$f', local_dir='$TARGET_DIR')"
    done
# Method 3: Run download inside Docker container
else
    echo "Downloading via Docker container (no host tools required)..."
    docker compose run --rm --entrypoint python3 comfyui -c "
from huggingface_hub import hf_hub_download
import os
for f in [${NEED_DOWNLOAD[@]/#/\"}]:
    print(f'Downloading {f}...')
    hf_hub_download(repo_id='Comfy-Org/Qwen-Image-2.1', filename=f, local_dir='/app/ComfyUI/models')
"
fi

echo "=========================================================="
echo " All Qwen-Image-2.1 models downloaded successfully!"
echo " You can now start ComfyUI with: ./start.sh"
echo "=========================================================="
