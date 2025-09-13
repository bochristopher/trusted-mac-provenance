#!/usr/bin/env bash
set -euo pipefail

OUT=${1:-photo.jpg}
SIGNED_OUT=${2:-verified_photo.jpg}

echo "📸 Capturing image from webcam..."

# 1) Capture from webcam
imagesnap -w 2 "$OUT"
echo "✅ Captured: $OUT"

# 2) Generate hash
echo "🔒 Generating hash..."
shasum -a 256 "$OUT" | awk '{print $1}' > "$OUT.sha256"

# 3) Sign the image (detached signature)
echo "✍️ Signing image..."
openssl dgst -sha256 -sign keys/device.key -out "$OUT.sig" "$OUT"

# 4) Create a simple manifest file (without C2PA for now)
echo "📋 Creating provenance manifest..."
cat > "$OUT.manifest" << EOF
{
  "version": "1.0",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "device": "Mac Webcam",
  "algorithm": "ECDSA-SHA256",
  "status": "signed",
  "label": "Captured on Mac (Week1 POC)",
  "files": {
    "image": "$OUT",
    "signature": "$OUT.sig",
    "hash": "$OUT.sha256"
  }
}
EOF

# 5) Copy original as "signed" version for now
cp "$OUT" "$SIGNED_OUT"

echo ""
echo "✅ Process complete!"
echo "   Original: $OUT"
echo "   Signed:   $SIGNED_OUT"
echo "   Hash:     $OUT.sha256"
echo "   Signature: $OUT.sig"
echo "   Manifest: $OUT.manifest"
echo ""
echo "Next: ./verify_simple.py $SIGNED_OUT"