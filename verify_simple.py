#!/usr/bin/env python3
import sys
import json
import hashlib
import os
from cryptography.hazmat.primitives import serialization, hashes
from cryptography.hazmat.primitives.asymmetric import ec, utils

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

def print_manifest_info(manifest_path):
    """Show manifest information."""
    try:
        print("\n--- Provenance Manifest ---")
        with open(manifest_path, 'r') as f:
            manifest = json.load(f)
        
        print(f"Version: {manifest.get('version', 'unknown')}")
        print(f"Timestamp: {manifest.get('timestamp', 'unknown')}")
        print(f"Device: {manifest.get('device', 'unknown')}")
        print(f"Algorithm: {manifest.get('algorithm', 'unknown')}")
        print(f"Label: {manifest.get('label', 'unknown')}")
        
    except Exception as e:
        print(f"Manifest info unavailable: {e}")

def main():
    if len(sys.argv) < 2:
        print("Usage: ./verify_simple.py <image>")
        print("Example: ./verify_simple.py verified_photo.jpg")
        sys.exit(1)
    
    asset = sys.argv[1]
    original = "photo.jpg"
    sig = f"{original}.sig"
    pub = "keys/device.pub"
    manifest = f"{original}.manifest"
    
    print(f"🔍 Verifying {asset}...")
    
    # Check if required files exist
    missing_files = []
    for required_file in [sig, pub, original]:
        if not os.path.exists(required_file):
            missing_files.append(required_file)
    
    if missing_files:
        print(f"❌ Required files not found: {', '.join(missing_files)}")
        print("Run ./capture_and_sign_simple.sh first")
        sys.exit(1)
    
    # Show manifest info if available
    if os.path.exists(manifest):
        print_manifest_info(manifest)
    
    # Verify signature
    print(f"\n🔐 Verifying cryptographic signature...")
    ok = verify_detached(pub, sig, original)
    
    # Final verdict
    print("\n" + "="*50)
    if ok:
        print("✅ VERIFIED - Image signature is valid")
        print("   This image has not been tampered with")
        print("   Cryptographic integrity confirmed")
        sys.exit(0)
    else:
        print("❌ TAMPERED - Image signature is invalid")
        print("   This image may have been modified")
        print("   Cryptographic verification failed")
        sys.exit(1)

if __name__ == "__main__":
    main()