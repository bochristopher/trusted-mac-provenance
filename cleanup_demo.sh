#!/usr/bin/env bash
set -euo pipefail

echo "🧹 Cleaning up demo files..."

# Remove generated photos and signatures
rm -f photo*.jpg *.sig *.sha256 *.manifest 2>/dev/null || true

# Keep keys but remove any test signatures
rm -f keys/*.sig keys/test* 2>/dev/null || true

echo "✅ Demo files cleaned up"
echo ""
echo "Ready for next demo run:"
echo "  ./visual_demo.sh"
echo "  ./quick_demo.sh" 
echo "  ./technical_demo.sh"