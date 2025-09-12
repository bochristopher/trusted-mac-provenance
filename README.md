#  Trusted Mac Provenance System

**Cryptographically signed webcam capture with tamper detection for macOS**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: macOS](https://img.shields.io/badge/Platform-macOS-blue.svg)](https://www.apple.com/macos/)
[![Crypto: ECDSA](https://img.shields.io/badge/Crypto-ECDSA--SHA256-green.svg)](https://en.wikipedia.org/wiki/Elliptic_Curve_Digital_Signature_Algorithm)

A proof-of-concept system for capturing images from Mac webcams with cryptographic signatures and embedded provenance metadata. Provides tamper detection and authenticity verification for trusted image workflows.

##  Features

-  **Webcam Capture** - Direct capture from built-in FaceTime cameras
-  **Cryptographic Signing** - ECDSA signatures with EC P-256 keys  
-  **Tamper Detection** - Detects any pixel-level modifications
-  **Provenance Metadata** - Embedded capture and signing details
-  **Hardware Ready** - Architecture for secure element integration
-  **Live Demo** - Interactive authenticity proof system

##  Quick Start

### Prerequisites
- macOS (tested on macOS 12+)
- [Homebrew](https://brew.sh)
- Python 3.8+

### Installation

```bash
# Clone repository
git clone https://github.com/yourusername/trusted-mac-provenance.git
cd trusted-mac-provenance

# Run setup
chmod +x manual_setup.sh
./manual_setup.sh
```

### Basic Usage

```bash
# 1. Capture and sign image
./capture_and_sign.sh

# 2. Verify signature
python3 verify_simple.py photo.jpg
# Output: ✅ VERIFIED - Image signature is valid

# 3. Test tamper detection  
python3 tamper_simple.py photo.jpg
python3 verify_simple.py photo_tampered.jpg
# Output: ❌ TAMPERED - Image signature is invalid
```

## 📱 Demo

### Interactive Authenticity Demo
```bash
chmod +x demo_authenticity.sh
./demo_authenticity.sh
```

This runs a complete interactive demonstration proving:
- Real cryptographic verification (not scripted)
- External tool confirmation with OpenSSL
- Detection of any image modifications
- Wrong key rejection
- Actual cryptographic evidence display

### Expected Output
```
✅ VERIFIED - Image signature is valid
   This image has not been tampered with
   Cryptographic integrity confirmed
```

##  Architecture

```
Webcam → imagesnap → ECDSA Sign → Provenance Embed → Verification
   ↓           ↓            ↓             ↓             ↓
photo.jpg  capture     signature     manifest    ✅/❌ Status
```

### Components

- **`manual_setup.sh`** - One-time system setup
- **`capture_and_sign.sh`** - Webcam capture and signing
- **`verify_simple.py`** - Signature verification  
- **`tamper_simple.py`** - Tamper testing utilities
- **`hardware_signer.py`** - Hardware security module support

## 🔧 Technical Details

### Cryptography
- **Algorithm**: ECDSA with SHA-256
- **Curve**: NIST P-256 (secp256r1)
- **Key Format**: PEM-encoded EC keys
- **Signature**: Detached binary signatures

### Security Model
- **Week 1**: Software keys (development/POC)
- **Week 2**: Hardware security modules (production)
- **Week 3**: Streaming support (planned)

### File Outputs
```
photo.jpg           # Original captured image
photo.jpg.sig       # Cryptographic signature  
photo.jpg.sha256    # SHA-256 hash
photo.jpg.manifest  # Provenance metadata
verified_photo.jpg  # Image with embedded manifest
```

##  Security Considerations

### Current Implementation (Week 1)
 **Development Only**: Uses software-stored private keys

### Production Deployment (Week 2+)
 **Hardware Security**: Integration with:
- ATECC608A secure elements
- macOS Secure Enclave (T2/Apple Silicon)  
- Hardware Security Modules (HSMs)

### Key Security
```bash
#  NEVER commit private keys to version control
#  Hardware keys cannot be extracted
#  Tamper detection triggers key erasure
```

##  Use Cases

- ** Journalism** - Tamper-proof evidence capture
- ** Legal Systems** - Court-admissible documentation  
- ** Medical Imaging** - HIPAA-compliant workflows
- ** Forensics** - Chain of custody preservation
- ** Content Verification** - Deepfake detection support

##  Testing

### Verify Setup
```bash
# Test key generation
openssl pkey -in keys/device.pub -pubin -text -noout

# Test signature verification  
openssl dgst -sha256 -verify keys/device.pub -signature photo.jpg.sig photo.jpg
```

### Manual Verification
```bash
# Compare hashes
shasum -a 256 photo.jpg
shasum -a 256 photo_tampered.jpg
# Should be completely different
```

##  Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

### Development Setup
```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

##  License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

##  Disclaimer

This is a proof-of-concept system. For production use:
- Use hardware-backed keys only
- Implement proper key management
- Add timestamp authorities for legal compliance
- Consider additional metadata standards (C2PA, etc.)

##  Related Projects

- [C2PA Specification](https://c2pa.org/) - Content Credentials standard
- [Project Origin](https://projectorigin.com/) - Media authenticity initiative  
- [ECDSA Standard](https://tools.ietf.org/html/rfc6979) - RFC 6979 specification

##  Support

- Create an [Issue](https://github.com/yourusername/trusted-mac-provenance/issues) for bug reports
- Start a [Discussion](https://github.com/yourusername/trusted-mac-provenance/discussions) for questions
- Check [Wiki](https://github.com/yourusername/trusted-mac-provenance/wiki) for detailed documentation

---

** Goal**: Establish cryptographic trust for digital media in an era of sophisticated manipulation tools.
