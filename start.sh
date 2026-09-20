#!/bin/bash
set -e

echo "Starting ComfyUI container..."
docker compose up -d

echo ""
echo "=========================================================="
echo " ComfyUI is up and running!"
echo " Web UI: http://localhost:8188"
echo " View logs: docker compose logs -f"
echo "=========================================================="
