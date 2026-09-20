#!/bin/bash
echo "Stopping ComfyUI container..."
docker compose --profile rtx3070 --profile jetson down
