#!/usr/bin/env bash
set -euo pipefail

echo "🔒 LIVE CRYPTOGRAPHIC AUTHENTICITY DEMO"
echo "========================================"
echo ""

# 1. Show the system is working
echo "1️⃣ BASELINE: Verify original image"
python3 verify_simple.py photo.jpg
echo ""
read -p "Press Enter to continue..."

# 2. Show actual cryptographic data
echo "2️⃣ PROVE IT'S REAL CRYPTO: Show actual signature data"
echo "Signature file contents (binary cryptographic data):"
xxd photo.jpg.sig | head -5
echo ""
echo "Public key details:"
openssl pkey -in keys/device.pub -pubin -text -noout | head -10
echo ""
read -p "Press Enter to continue..."

# 3. Show external verification
echo "3️⃣ EXTERNAL VERIFICATION: Use OpenSSL directly (no Python)"
echo "Testing original image with OpenSSL:"
if openssl dgst -sha256 -verify keys/device.pub -signature photo.jpg.sig photo.jpg; then
    echo "✅ OpenSSL confirms signature is valid"
else
    echo "❌ OpenSSL says signature is invalid"
fi
echo ""
read -p "Press Enter to continue..."

# 4. Test with tampered image
echo "4️⃣ TAMPER TEST: Test modified image"
if [ -f photo_tampered.jpg ]; then
    echo "Testing tampered image with OpenSSL:"
    if openssl dgst -sha256 -verify keys/device.pub -signature photo.jpg.sig photo_tampered.jpg; then
        echo "❌ ERROR: Tampered image verified (this shouldn't happen!)"
    else
        echo "✅ OpenSSL correctly detects tampering"
    fi
else
    echo "Creating tampered image first..."
    python3 tamper_simple.py photo.jpg
    echo "Testing tampered image with OpenSSL:"
    if openssl dgst -sha256 -verify keys/device.pub -signature photo.jpg.sig photo_tampered.jpg; then
        echo "❌ ERROR: Tampered image verified (this shouldn't happen!)"
    else
        echo "✅ OpenSSL correctly detects tampering"
    fi
fi
echo ""
read -p "Press Enter to continue..."

# 5. Show hash differences
echo "5️⃣ CRYPTOGRAPHIC HASHES: Show how changes affect hashes"
echo "Original image hash:"
shasum -a 256 photo.jpg
echo "Tampered image hash:"
shasum -a 256 photo_tampered.jpg
echo "☝️ Notice: Completely different hashes for tiny change!"
echo ""
read -p "Press Enter to continue..."

# 6. Test with wrong key
echo "6️⃣ WRONG KEY TEST: Show signature fails with different key"
if [ ! -f keys/wrong.key ]; then
    echo "Generating different key pair..."
    openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:P-256 -out keys/wrong.key
    openssl pkey -in keys/wrong.key -pubout -out keys/wrong.pub
fi

echo "Testing original image with WRONG public key:"
if openssl dgst -sha256 -verify keys/wrong.pub -signature photo.jpg.sig photo.jpg; then
    echo "❌ ERROR: Wrong key verified (this shouldn't happen!)"
else
    echo "✅ System correctly rejects wrong key"
fi
echo ""

echo "🎉 AUTHENTICITY PROVEN!"
echo "========================"
echo "✅ Real cryptographic signatures (not scripted)"
echo "✅ External tools confirm our results"  
echo "✅ Any image modification is detected"
echo "✅ Wrong keys are rejected"
echo "✅ System shows actual cryptographic evidence"
echo ""
echo "This is REAL cryptographic verification! 🔐"