#!/bin/bash

set -e

PROGRAM_NAME="gitmulti"
INSTALL_DIR="/usr/local/bin"
CPP_FILE="gitmulti.cpp"
EXE_PATH="$INSTALL_DIR/$PROGRAM_NAME"

echo "[*] Checking for required C++ compiler..."

if command -v clang++ >/dev/null 2>&1; then
    COMPILER="clang++"
elif command -v g++ >/dev/null 2>&1; then
    COMPILER="g++"
else
    echo "[!] Neither clang++ nor g++ is installed. Please install one with your package manager."
    exit 1
fi

# Check for LLVM clang++ on macOS, offer to install via Homebrew if needed
if [[ "$OSTYPE" == "darwin"* ]] && ! clang++ --version | grep -qi "llvm"; then
    echo "[!] Your clang++ does not appear to be from LLVM."
    read -p "    Would you like to install LLVM via Homebrew? [y/N]: " answer
    if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
        if ! command -v brew >/dev/null 2>&1; then
            echo "[!] Homebrew is not installed. Please install it first: https://brew.sh/"
            exit 1
        fi
        echo "[*] Installing LLVM..."
        brew install llvm
        LLVM_CLANG="$(brew --prefix llvm)/bin/clang++"
        if [[ -f "$LLVM_CLANG" ]]; then
            COMPILER="$LLVM_CLANG"
            echo "[*] Using LLVM clang++ at: $COMPILER"
        fi
    fi
fi

echo "[*] Compiling $CPP_FILE with $COMPILER..."
"$COMPILER" -std=c++17 "$CPP_FILE" -o "$PROGRAM_NAME"

echo "[*] Installing to $EXE_PATH (requires sudo)..."
sudo mv "$PROGRAM_NAME" "$EXE_PATH"
sudo chmod +x "$EXE_PATH"

echo "[✓] Installed $PROGRAM_NAME"
echo "You can now run: $PROGRAM_NAME"
