#!/usr/bin/env python3
import sys
import os

def tamper_image(path):
    """Flip one bit in an image to simulate tampering."""
    print(f"🔧 Tampering with {path}...")
    
    if not os.path.exists(path):
        print(f"❌ File not found: {path}")
        return None
    
    with open(path, "rb") as f:
        data = bytearray(f.read())

    # Flip one byte in the middle
    idx = len(data) // 2
    original_byte = data[idx]
    data[idx] ^= 0x01
    
    tampered = path.replace(".jpg", "_tampered.jpg")
    with open(tampered, "wb") as f:
        f.write(data)

    print(f"✅ Created {tampered}")
    print(f"   Flipped bit at position {idx}")
    print(f"   Changed byte: 0x{original_byte:02x} → 0x{data[idx]:02x}")
    
    return tampered

def main():
    path = sys.argv[1] if len(sys.argv) > 1 else "photo.jpg"
    
    if not os.path.exists(path):
        print(f"❌ File not found: {path}")
        print("Run ./capture_and_sign.sh first")
        sys.exit(1)
    
    # Create tampered version
    tampered = tamper_image(path)
    
    if tampered:
        print(f"\n💡 Tampered image created!")
        print(f"   Original: {path}")
        print(f"   Tampered: {tampered}")
        print(f"\n🧪 Test verification:")
        print(f"   python3 verify_simple.py {path}       # Should show ✅ VERIFIED")
        print(f"   python3 verify_simple.py {tampered}   # Should show ❌ TAMPERED")

if __name__ == "__main__":
    main()