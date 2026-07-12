#!/bin/sh
# Install packages from a packages file into a Docker runtime container.
# Usage: bootstrap-docker-release.sh <packages-file>
# Fails hard if any package cannot be installed.
set -eu

PACKAGES_FILE="${1:?Usage: $0 <packages-file>}"

echo "https://dl-cdn.alpinelinux.org/alpine/edge/main" > /etc/apk/repositories
echo "https://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories
apk update

while IFS= read -r pkg || [ -n "$pkg" ]; do
    case "$pkg" in
        \#*|"") continue ;;
    esac
    echo "Installing: $pkg"
    apk add --no-cache "$pkg"
done < "$PACKAGES_FILE"
