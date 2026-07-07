#!/bin/bash
set -euo pipefail

SRC_DIR="$(realpath "$(dirname "$0")/..")"
BUILD_DIR="${SRC_DIR}/build"
BIN_DIR="${BUILD_DIR}/bin"
REPOS="cpm cognitiveosd cli inference core-mcp-bridges"

mkdir -p "${BIN_DIR}"

for repo in ${REPOS}; do
    SRC_PATH="$(realpath "${SRC_DIR}/../${repo}")"
    if [ ! -d "${SRC_PATH}" ]; then
        echo "Cloning ${repo} from GitHub..."
        git clone --depth=1 "https://github.com/CognitiveOS-Project/${repo}.git" "${SRC_PATH}"
    fi
done

for repo in ${REPOS}; do
    SRC_PATH="$(realpath "${SRC_DIR}/../${repo}")"
    echo "  -> Building ${repo}..."
    cd "${SRC_PATH}"
    if [ -f Makefile ]; then
        make build
    elif [ -f scripts/build.sh ]; then
        bash scripts/build.sh
    else
        echo "  ERROR: no Makefile or scripts/build.sh in ${repo}"
        exit 1
    fi
    if [ -d build/bin ]; then
        cp -a build/bin/* "${BIN_DIR}/" 2>/dev/null || true
    fi
done

echo ""
echo "All binaries in ${BIN_DIR}:"
ls -la "${BIN_DIR}/"
