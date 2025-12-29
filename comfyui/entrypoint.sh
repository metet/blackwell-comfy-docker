#!/usr/bin/env bash

# ComfyUI Docker Startup File - Replicable v1.1
set -e

# Define Variables
PYTHON_BIN="/home/comfyuser/venv/bin/python3"
CN_DIR="/app/ComfyUI/custom_nodes"
CFG_DIR="/app/ComfyUI/user/default/ComfyUI-Manager"
INIT_MARKER="$CN_DIR/.custom_nodes_initialized"

# 2. Setup ComfyUI-Manager Config
mkdir -p "$CFG_DIR"
CFG_FILE="$CFG_DIR/config.ini"
SQLITE_URL="sqlite:////${CFG_DIR}/manager.db"

if [ ! -f "$CFG_FILE" ]; then
    echo "↳ Initializing Manager config..."
    cat > "$CFG_FILE" <<EOF
[default]
use_uv = False
file_logging = False
db_mode = cache
database_url = ${SQLITE_URL}
EOF
fi

# 3. Initialize Essential Custom Nodes
declare -A REPOS=(
    ["ComfyUI-Manager"]="https://github.com/ltdrdata/ComfyUI-Manager.git"
    ["ComfyUI_essentials"]="https://github.com/cubiq/ComfyUI_essentials.git"
    ["ComfyUI-Crystools"]="https://github.com/crystian/ComfyUI-Crystools.git"
    ["rgthree-comfy"]="https://github.com/rgthree/rgthree-comfy.git"
 #   ["ComfyUI-KJNodes"]="https://github.com/kijai/ComfyUI-KJNodes.git"
)

if [ ! -f "$INIT_MARKER" ]; then
    echo "↳ First run: Cloning nodes to host volumes..."
    for name in "${!REPOS[@]}"; do
        target="$CN_DIR/$name"
        [ ! -d "$target" ] && git clone --depth 1 "${REPOS[$name]}" "$target"
    done

    echo "↳ Installing node dependencies..."
    for dir in "$CN_DIR"/*/; do
        [ -f "${dir}requirements.txt" ] && $PYTHON_BIN -m pip install --no-cache-dir -r "${dir}requirements.txt"
    done
    touch "$INIT_MARKER"
fi

# 5. Pre-flight Initialization
# Forces ComfyUI to build internal mappings before the port is even open
echo "↳ Initializing ComfyUI Internal Mappings..."
$PYTHON_BIN main.py --quick-test-for-ci

echo "↳ Launching ComfyUI for RTX 5080..."
exec "$@"
