#!/bin/bash

set -e

PROGRAM_NAME="gitmulti"
INSTALL_DIR="/usr/local/bin"
CPP_FILE="gitmulti.cpp"
EXE_PATH="$INSTALL_DIR/$PROGRAM_NAME"

# Check for g++
if ! command -v g++ >/dev/null 2>&1; then
    echo "[!] g++ is not installed. Please install it with your package manager."
    exit 1
fi

# Compile
echo "[*] Compiling $CPP_FILE..."
g++ "$CPP_FILE" -o "$PROGRAM_NAME"

# Install
echo "[*] Installing to $EXE_PATH (requires sudo)..."
sudo mv "$PROGRAM_NAME" "$EXE_PATH"
sudo chmod +x "$EXE_PATH"

echo "[✓] Installed $PROGRAM_NAME"
echo "You can now run: $PROGRAM_NAME"
