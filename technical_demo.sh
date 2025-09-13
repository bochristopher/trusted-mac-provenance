#!/usr/bin/env bash
set -euo pipefail

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
WHITE='\033[1;37m'
CYAN='\033[0;36m'
NC='\033[0m'

show_technical_details() {
    echo -e "${WHITE}🔐 TECHNICAL CRYPTOGRAPHIC DEMONSTRATION${NC}"
    echo "========================================================"
    echo ""
    
    # Show key details
    echo -e "${BLUE}📋 CRYPTOGRAPHIC SETUP${NC}"
    echo "Algorithm: ECDSA with SHA-256"
    echo "Curve: NIST P-256 (secp256r1)"
    echo "Key size: 256 bits"
    echo ""
    
    # Show actual key structure
    echo -e "${CYAN}🔑 Private Key Structure:${NC}"
    openssl pkey -in keys/device.key -text -noout | head -15
    echo ""
    
    echo -e "${CYAN}🔓 Public Key (PEM format):${NC}"
    cat keys/device.pub
    echo ""
    
    read -p "Press ENTER to capture and analyze image..."
    
    # Clean slate
    rm -f photo*.jpg *.sig *.sha256 *.manifest 2>/dev/null || true
    
    # Capture with technical details
    echo -e "${BLUE}📸 Capturing image...${NC}"
    imagesnap -w 2 photo.jpg
    
    # Show image metadata
    echo -e "${CYAN}📊 Image Analysis:${NC}"
    file photo.jpg
    ls -la photo.jpg
    echo ""
    
    # Hash analysis
    echo -e "${BLUE}🔢 Hash Calculation (SHA-256):${NC}"
    echo "Command: shasum -a 256 photo.jpg"
    shasum -a 256 photo.jpg | tee photo.jpg.sha256
    echo ""
    echo "Hash length: $(cat photo.jpg.sha256 | awk '{print length($1)}') characters (256 bits)"
    echo "Hash entropy: ~256 bits of security"
    echo ""
    
    # Signature creation with details
    echo -e "${BLUE}✍️  Signature Creation:${NC}"
    echo "Command: openssl dgst -sha256 -sign keys/device.key -out photo.jpg.sig photo.jpg"
    openssl dgst -sha256 -sign keys/device.key -out photo.jpg.sig photo.jpg
    
    # Signature analysis
    echo -e "${CYAN}🔐 Signature Analysis:${NC}"
    ls -la photo.jpg.sig
    echo "Signature format: DER-encoded ECDSA"
    echo "Signature components: (r, s) pair"
    echo ""
    echo "Raw signature bytes (hex):"
    xxd photo.jpg.sig | head -8
    echo ""
    
    # ASN.1 structure
    echo -e "${CYAN}📱 ASN.1 Signature Structure:${NC}"
    openssl asn1parse -inform DER -in photo.jpg.sig
    echo ""
    
    # Verification with technical details
    echo -e "${BLUE}🔍 Verification Process:${NC}"
    echo "1. Parse signature: Extract (r,s) from DER encoding"
    echo "2. Hash image: SHA-256(image_data)"
    echo "3. Verify: ECDSA_verify(hash, signature, public_key)"
    echo ""
    
    # Show verification math
    echo -e "${CYAN}🧮 Verification Command:${NC}"
    echo "openssl dgst -sha256 -verify keys/device.pub -signature photo.jpg.sig photo.jpg"
    if openssl dgst -sha256 -verify keys/device.pub -signature photo.jpg.sig photo.jpg; then
        echo -e "${GREEN}✅ Cryptographic verification: SUCCESS${NC}"
    else
        echo -e "${RED}❌ Cryptographic verification: FAILED${NC}"
    fi
    echo ""
    
    # Show image
    open photo.jpg
    echo "📱 Original image displayed"
    echo ""
    
    read -p "Press ENTER to demonstrate tampering..."
    
    # Tampering analysis
    echo -e "${YELLOW}🔧 TAMPERING SIMULATION${NC}"
    echo "Creating modified image by flipping 1 bit..."
    python3 tamper_simple.py photo.jpg
    
    # Hash comparison
    echo -e "${CYAN}📊 Hash Comparison:${NC}"
    echo "Original:  $(cat photo.jpg.sha256)"
    echo "Tampered:  $(shasum -a 256 photo_tampered.jpg | awk '{print $1}')"
    echo ""
    echo "Hamming distance: ~128 bits different (avalanche effect)"
    echo "Probability of collision: 1 in 2^256 ≈ 1.16 × 10^77"
    echo ""
    
    # Show tampered image
    open photo_tampered.jpg
    echo "📱 Tampered image displayed (visually identical)"
    echo ""
    
    # Technical verification failure
    echo -e "${RED}🚨 TAMPER DETECTION${NC}"
    echo "Testing tampered image against original signature..."
    if openssl dgst -sha256 -verify keys/device.pub -signature photo.jpg.sig photo_tampered.jpg; then
        echo -e "${RED}❌ ERROR: Should have failed!${NC}"
    else
        echo -e "${GREEN}✅ Correctly detected tampering${NC}"
    fi
    echo ""
    
    # Security analysis
    echo -e "${WHITE}🔒 SECURITY ANALYSIS${NC}"
    echo "Attack vectors and defenses:"
    echo "✅ Brute force: 2^256 operations (computationally infeasible)"
    echo "✅ Hash collision: SHA-256 resistance > 2^128"
    echo "✅ Key recovery: ECDLP on P-256 (industry standard)"
    echo "✅ Signature forgery: Requires private key or hash collision"
    echo "⚠️  Key compromise: Week-2 hardware integration mitigates"
    echo ""
    
    # Performance metrics
    echo -e "${CYAN}⚡ PERFORMANCE METRICS${NC}"
    echo "Capture time: ~3 seconds (camera warm-up)"
    echo "Hash time: <100ms for typical image"
    echo "Signature time: <50ms (EC operations)"
    echo "Verification time: <50ms (public key operations)"
    echo "Storage overhead: ~70 bytes signature + 64 bytes hash"
    echo ""
    
    echo -e "${WHITE}🎯 TECHNICAL DEMO COMPLETE${NC}"
    echo "Demonstrated: Real-world cryptographic security"
    echo "Ready for: Hardware security module integration"
    echo ""
}

show_technical_details