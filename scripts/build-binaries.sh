#!/bin/bash
# Orchestrate per-repo builds — each repo owns its own build process
set -euo pipefail

BUILD_DIR="$(realpath "$(dirname "$0")/..")/build"
BIN_DIR="${BUILD_DIR}/bin"
mkdir -p "${BIN_DIR}"

# Clone or update repos
REPOS="cpm cognitiveosd cli inference core-mcp-bridges"
for repo in ${REPOS}; do
    SRC_PATH="$(realpath "$(dirname "$0")/..")/../${repo}"
    if [ ! -d "${SRC_PATH}" ]; then
        echo "Cloning ${repo} from GitHub..."
        git clone --depth=1 "https://github.com/CognitiveOS-Project/${repo}.git" "${SRC_PATH}"
    fi
done

# Build each repo using its own Makefile (or scripts/build.sh)
for repo in ${REPOS}; do
    SRC_PATH="$(realpath "$(dirname "$0")/..")/../${repo}"
    echo ""
    echo "==> Building ${repo}..."
    cd "${SRC_PATH}"
    if [ -f Makefile ]; then
        make build
    elif [ -f scripts/build.sh ]; then
        bash scripts/build.sh
    else
        echo "  ERROR: no Makefile or scripts/build.sh found in ${repo}"
        exit 1
    fi
    # Collect binaries
    if [ -d build/bin ]; then
        cp -a build/bin/* "${BIN_DIR}/" 2>/dev/null || true
    fi
    echo "  -> ${repo} binaries collected"
done

# Special handling: inference CGo build (llama.cpp)
# The inference Makefile handles this when vendor/llama.cpp exists,
# but build-binaries.sh also clones it if missing
INFERENCE_DIR="$(realpath "$(dirname "$0")/..")/../inference"
LLAMA_CPP_DIR="${INFERENCE_DIR}/vendor/llama.cpp"
if [ -f "${LLAMA_CPP_DIR}/CMakeLists.txt" ]; then
    echo ""
    echo "==> llama.cpp already vendored — inference built with CGo"
else
    echo ""
    echo "==> Note: llama.cpp not vendored — inference built with CGO_ENABLED=0 (mock backend)"
fi

echo ""
echo "All binaries in ${BIN_DIR}:"
ls -la "${BIN_DIR}/"
