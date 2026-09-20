#!/bin/bash
set -e

# 1. Ensure 'python' command exists
command -v python >/dev/null 2>&1 || ln -sf $(which python3) /usr/local/bin/python

# Ensure ComfyUI-Manager dependencies (toml, uv) are installed
if ! python3 -c "import toml" >/dev/null 2>&1; then
    echo "[Entrypoint] Installing ComfyUI-Manager dependencies (toml, uv)..."
    pip3 install --no-cache-dir toml uv 2>/dev/null || true
fi

# 2. Fix PyTorch 2.6 schema inference for PEP 585 generics (list[int]) used by comfy-kitchen
python3 -c '
path = "/usr/local/lib/python3.10/dist-packages/torch/_library/infer_schema.py"
try:
    content = open(path).read()
    target = "if annotation_type not in SUPPORTED_PARAM_TYPES.keys():"
    if "annotation_type.__origin__ is list" not in content and target in content:
        patch = "if hasattr(annotation_type, \"__origin__\") and annotation_type.__origin__ is list:\n            annotation_type = typing.List[annotation_type.__args__[0]]\n        " + target
        open(path, "w").write(content.replace(target, patch, 1))
        print("[Entrypoint] Applied PyTorch PEP-585 schema patch successfully.")
except Exception as e:
    print(f"[Entrypoint] Schema patch note: {e}")
'

# Determine ComfyUI directory
COMFY_DIR="${COMFY_DIR:-/app/ComfyUI}"
if [ ! -d "$COMFY_DIR" ] && [ -d "/comfyui" ]; then
    COMFY_DIR="/comfyui"
fi

# 3. Ensure ComfyUI-Manager is installed in custom_nodes
if [ ! -d "$COMFY_DIR/custom_nodes/ComfyUI-Manager" ]; then
    echo "[Entrypoint] Installing ComfyUI-Manager in custom_nodes..."
    git clone --depth 1 https://github.com/ltdrdata/ComfyUI-Manager.git "$COMFY_DIR/custom_nodes/ComfyUI-Manager" || true
fi

# 4. Auto-populate Qwen-Image-2.1 workflow templates in user workflows directory
mkdir -p "$COMFY_DIR/user/default/workflows"
if [ -d "/app/workflows" ]; then
    cp -n /app/workflows/*.json "$COMFY_DIR/user/default/workflows/" 2>/dev/null || true
fi

# 5. Check if Qwen-Image-2.1 models are present
DIFF_MODEL="$COMFY_DIR/models/diffusion_models/qwen_image_2.1_int8_convrot.safetensors"
if [ ! -f "$DIFF_MODEL" ]; then
    echo "=========================================================================="
    echo " [WARNING] Qwen-Image-2.1 diffusion model not found!"
    echo " Target: $DIFF_MODEL"
    echo " Please run ./download_models.sh on your host machine to download models."
    echo "=========================================================================="
fi

CLI_ARGS=${CLI_ARGS:-"--listen 0.0.0.0 --port 8188 --reserve-vram 2.5 --lowvram --fp16-vae"}

echo "=============================================="
echo " Starting ComfyUI with Qwen-Image-2.1 Support "
echo " Working directory: ${COMFY_DIR}"
echo " Flags: ${CLI_ARGS} $@"
echo "=============================================="

cd "$COMFY_DIR"
exec python3 main.py ${CLI_ARGS} "$@"
