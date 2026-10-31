#!/usr/bin/env bash
# ==============================================================================
# Namma Ooru AI – Render Static Site Build Script
# ==============================================================================
set -e

echo "=== [1/4] Checking and Installing Flutter SDK ==="
if command -v flutter >/dev/null 2>&1; then
    echo ">> Flutter is already installed:"
    flutter --version
else
    echo ">> Flutter not found in system PATH. Installing Flutter stable..."
    INSTALL_DIR="$HOME/flutter"
    if [ ! -d "$INSTALL_DIR" ]; then
        git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$INSTALL_DIR"
    fi
    export PATH="$INSTALL_DIR/bin:$PATH"
    echo ">> Flutter installation complete:"
    flutter --version
fi

echo "=== [2/4] Resolving Flutter Dependencies ==="
flutter pub get

echo "=== [3/4] Building Flutter Web Release Bundle ==="
flutter build web --release --no-wasm-dry-run --base-href /

echo "=== [4/4] Verifying Build Output ==="
if [ ! -f "build/web/index.html" ]; then
    echo "ERROR: build/web/index.html not found!"
    exit 1
fi

echo ">> Build verified successfully. Artifacts in build/web:"
ls -la build/web

echo "=== Build Complete ==="
