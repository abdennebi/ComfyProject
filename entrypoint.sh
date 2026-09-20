#!/bin/bash
set -e

# Fix PyTorch 2.6 schema inference for PEP 585 generics (list[int]) used by comfy-kitchen
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

CLI_ARGS=${CLI_ARGS:-"--listen 0.0.0.0 --port 8188"}

echo "=============================================="
echo " Starting ComfyUI with Qwen-Image-2.1 Support "
echo " Flags: ${CLI_ARGS} $@"
echo "=============================================="

exec python3 main.py ${CLI_ARGS} "$@"
