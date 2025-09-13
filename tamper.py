#!/usr/bin/env python3
import sys
import os
from verify import verify_detached

def sha256_file(path):
    """Calculate SHA256 hash of a file."""
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(65536), b""):
            h.update(chunk)
    return h.digest()

def verify_detached(pub_pem, sig_path, file_path):
    """Verify a detached ECDSA signature."""
    try:
        with open(pub_pem, "rb") as f:
            pub = serialization.load_pem_public_key(f.read())
        
        with open(sig_path, "rb") as f:
            sig = f.read()
        
        digest = sha256_file(file_path)
        pub.verify(sig, digest, ec.ECDSA(utils.Prehashed(hashes.SHA256())))
        return True
    except Exception as e:
        print(f"Verification failed: {e}")
        return False

def tamper_image(path):
    """Flip one bit in an image to simulate tampering."""
    print(f"🔧 Tampering with {path}...")
    
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

def test_tamper_detection(original, tampered):
    """Test that tampering is detected."""
    print(f"\n🧪 Testing tamper detection...")
    print(f"   Original: {original}")
    print(f"   Tampered: {tampered}")
    
    # Verify original against original signature (should pass)
    ok_original = verify_detached("keys/device.pub", f"{original}.sig", original)
    
    # Verify tampered against original signature (should fail)
    ok_tampered = verify_detached("keys/device.pub", f"{original}.sig", tampered)
    
    print(f"\n📊 Results:")
    print(f"   Original verification: {'✅ PASS' if ok_original else '❌ FAIL'}")
    print(f"   Tampered verification: {'❌ FAIL (expected)' if not ok_tampered else '✅ UNEXPECTED PASS'}")
    
    if ok_original and not ok_tampered:
        print(f"\n🎉 SUCCESS: Tamper detection working correctly!")
    else:
        print(f"\n⚠️  WARNING: Unexpected verification results")

def main():
    path = sys.argv[1] if len(sys.argv) > 1 else "photo.jpg"
    
    if not os.path.exists(path):
        print(f"❌ File not found: {path}")
        print("Run ./capture_and_sign.sh first")
        sys.exit(1)
    
    if not os.path.exists(f"{path}.sig"):
        print(f"❌ Signature file not found: {path}.sig")
        print("Run ./capture_and_sign.sh first")
        sys.exit(1)
    
    # Create tampered version
    tampered = tamper_image(path)
    
    # Test detection
    test_tamper_detection(path, tampered)
    
    print(f"\n💡 Demo complete!")
    print(f"   You can now run: ./verify.py {tampered}")
    print(f"   It should show ❌ TAMPERED")

if __name__ == "__main__":
    main()