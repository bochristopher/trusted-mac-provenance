#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Manual setup for trusted Mac provenance system..."

# 1. Install Homebrew tools
echo "Installing required tools..."
brew install openssl imagesnap python

# 2. Try to install cryptography (needed for verification)
echo "Installing cryptography..."
if python3 -m pip install --user cryptography; then
    echo "✅ Cryptography installed successfully"
else
    echo "⚠️  Cryptography installation failed - verification may not work"
fi

# 3. Generate cryptographic keys
echo "Generating cryptographic keys..."
mkdir -p keys

if [ ! -f keys/device.key ]; then
    # Generate EC P-256 private key
    openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:P-256 -out keys/device.key
    echo "✅ Generated private key: keys/device.key"
else
    echo "✅ Using existing private key: keys/device.key"
fi

if [ ! -f keys/device.pub ]; then
    # Extract public key
    openssl pkey -in keys/device.key -pubout -out keys/device.pub
    echo "✅ Generated public key: keys/device.pub"
else
    echo "✅ Using existing public key: keys/device.pub"
fi

# 4. Make scripts executable
echo "Making scripts executable..."
chmod +x capture_and_sign_simple.sh verify_simple.py tamper.py

# 5. Test basic functionality
echo "Testing key generation..."
if openssl pkey -in keys/device.key -text -noout > /dev/null 2>&1; then
    echo "✅ Private key is valid"
else
    echo "❌ Private key validation failed"
    exit 1
fi

if openssl pkey -in keys/device.pub -pubin -text -noout > /dev/null 2>&1; then
    echo "✅ Public key is valid"
else
    echo "❌ Public key validation failed"
    exit 1
fi

echo ""
echo "✅ Manual setup complete!"
echo ""
echo "Ready to use:"
echo "  ./capture_and_sign_simple.sh   # Capture and sign image"
echo "  ./verify_simple.py photo.jpg   # Verify signature"
echo "  ./tamper.py photo.jpg          # Test tamper detection"
echo ""
echo "Note: Using simplified version without C2PA (full C2PA can be added later)"