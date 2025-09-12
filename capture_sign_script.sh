#!/usr/bin/env bash
set -euo pipefail

OUT=${1:-photo.jpg}
SIGNED_OUT=${2:-verified_photo.jpg}

echo "📸 Capturing image from webcam..."

# 1) Capture from webcam
imagesnap -w 2 "$OUT"  # waits 2s, then takes a photo
echo "✅ Captured: $OUT"

# 2) Hash the image
echo "🔒 Generating hash..."
shasum -a 256 "$OUT" | awk '{print $1}' > "$OUT.sha256"

# 3) Sign the image (detached signature)
echo "✍️ Signing image..."
openssl dgst -sha256 -sign keys/device.key -out "$OUT.sig" "$OUT"

# 4) Embed a C2PA manifest that records signature as an assertion
echo "📋 Embedding C2PA manifest..."
python3 -m c2pa add "$OUT" \
  --assertion signature="$OUT.sig" \
  --label "Captured on Mac (Week1 POC)" \
  --out "$SIGNED_OUT"

echo ""
echo "✅ Process complete!"
echo "   Original: $OUT"
echo "   Signed:   $SIGNED_OUT"
echo "   Hash:     $OUT.sha256"
echo "   Signature: $OUT.sig"
echo ""
echo "Next: ./verify.py $SIGNED_OUT"