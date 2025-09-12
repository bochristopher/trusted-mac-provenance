#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Setting up trusted Mac provenance system..."

# Homebrew (install if missing)
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || true
fi

# Tools
echo "Installing required tools..."
brew install python openssl imagesnap

# Python deps
echo "Installing Python dependencies..."
python3 -m pip install --upgrade pip
python3 -m pip install c2pa cryptography

# Keys (software key for week 1)
echo "Generating cryptographic keys..."
mkdir -p keys
if [ ! -f keys/device.key ]; then
  # EC P-256 keypair
  openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:P-256 -out keys/device.key
  openssl pkey -in keys/device.key -pubout -out keys/device.pub
  echo "✅ Generated new EC P-256 keypair"
else
  echo "✅ Using existing keypair"
fi

echo ""
echo "✅ Setup complete!"
echo "Next steps:"
echo "  ./capture_and_sign.sh"
echo "  ./verify.py verified_photo.jpg"