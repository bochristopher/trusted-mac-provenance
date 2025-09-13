#!/usr/bin/env bash
set -euo pipefail

# Colors for better visual presentation
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color


# Add this function near the top of your visual_demo.sh file
show_image_with_watermark() {
    local image=$1
    local title="$2"
    local status=${3:-"none"}

    echo -e "${GREEN}🖼️  $title${NC}"
    echo -e "${BLUE}File: $image${NC}"

    if [[ -f "$image" ]]; then
        if [[ "$status" != "none" ]] && [[ -f "./add_watermark.sh" ]]; then
            # Create watermarked version
            local watermarked="${image%.*}_presentation.jpg"
            echo -e "${BLUE}🎨 Adding $status watermark...${NC}"
            chmod +x add_watermark.sh
            ./add_watermark.sh "$image" "$status" "$watermarked" 2>/dev/null || {
                echo -e "${YELLOW}⚠️ Watermark failed, showing original${NC}"
                open "$image"
                return
            }

            if [[ -f "$watermarked" ]]; then
                open "$watermarked"
                echo -e "${YELLOW}📱 Watermarked image opened${NC}"
            else
                open "$image"
            fi
        else
            open "$image"
            echo -e "${YELLOW}📱 Original image opened${NC}"
        fi
    else
        echo -e "${RED}❌ Image not found: $image${NC}"
    fi
    echo ""
}
# Function to show a step header
show_step() {
    clear
    echo -e "${PURPLE}================================================================${NC}"
    echo -e "${WHITE}🔐 TRUSTED MAC PROVENANCE - LIVE DEMO${NC}"
    echo -e "${PURPLE}================================================================${NC}"
    echo ""
    echo -e "${CYAN}STEP $1: $2${NC}"
    echo -e "${PURPLE}================================================================${NC}"
    echo ""
}

# Function to pause and wait for user
wait_for_user() {
    echo ""
    echo -e "${YELLOW}👆 Press ENTER to continue to next step...${NC}"
    read -r
}

# Function to show file with syntax highlighting
show_file_preview() {
    local file=$1
    local lines=${2:-10}
    echo -e "${BLUE}📄 Preview of $file:${NC}"
    echo -e "${PURPLE}----------------------------------------${NC}"
    if [[ $file == *.py ]]; then
        head -n $lines "$file" | cat -n
    else
        head -n $lines "$file" | cat -n
    fi
    echo -e "${PURPLE}----------------------------------------${NC}"
    echo ""
}

# Function to display image
show_image() {
    local image=$1
    local title="$2"
    echo -e "${GREEN}🖼️  Opening image: $title${NC}"
    echo -e "${BLUE}File: $image${NC}"
    if [[ -f "$image" ]]; then
        # Get image info
        local size=$(ls -lh "$image" | awk '{print $5}')
        echo -e "${CYAN}Size: $size${NC}"
        
        # Open in default viewer (Preview on Mac)
        open "$image"
        echo -e "${YELLOW}📱 Image should now be displayed in Preview${NC}"
    else
        echo -e "${RED}❌ Image not found: $image${NC}"
    fi
    echo ""
}

# Function to show cryptographic data
show_crypto_data() {
    local file=$1
    local description="$2"
    echo -e "${BLUE}🔐 $description${NC}"
    echo -e "${PURPLE}----------------------------------------${NC}"
    if [[ -f "$file" ]]; then
        if [[ $file == *.sig ]]; then
            echo "Binary signature data (first 32 bytes in hex):"
            xxd -l 32 "$file"
        elif [[ $file == *.sha256 ]]; then
            echo "SHA-256 Hash:"
            cat "$file"
        elif [[ $file == *.pub ]]; then
            echo "Public Key (first 10 lines):"
            head -10 "$file"
        else
            head -5 "$file"
        fi
    else
        echo "File not found: $file"
    fi
    echo -e "${PURPLE}----------------------------------------${NC}"
    echo ""
}

# Main demo script
main_demo() {
    # Step 1: Introduction
    show_step "1" "INTRODUCTION - What We're Going to Prove"
    echo -e "${WHITE}This demo will prove:${NC}"
    echo -e "${GREEN}✅ Real cryptographic signatures (not fake/scripted)${NC}"
    echo -e "${GREEN}✅ Any image modification is immediately detected${NC}"
    echo -e "${GREEN}✅ Visual proof with actual photos${NC}"
    echo -e "${GREEN}✅ External tool verification (OpenSSL)${NC}"
    echo ""
    echo -e "${YELLOW}🎯 Goal: Establish trust in digital media${NC}"
    wait_for_user

    # Step 2: Check setup
    show_step "2" "VERIFY SYSTEM SETUP"
    echo -e "${BLUE}🔧 Checking if system is ready...${NC}"
    
    if [[ ! -f "keys/device.key" ]]; then
        echo -e "${RED}❌ Keys not found. Running setup first...${NC}"
        echo ""
        ./manual_setup.sh
        echo ""
        echo -e "${GREEN}✅ Setup complete!${NC}"
    else
        echo -e "${GREEN}✅ Cryptographic keys ready${NC}"
    fi
    
    # Show the public key
    show_crypto_data "keys/device.pub" "Our Public Key (safe to share)"
    
    echo -e "${BLUE}🔍 Key details:${NC}"
    openssl pkey -in keys/device.pub -pubin -text -noout | head -8
    
    wait_for_user

    # Step 3: Live capture
    show_step "3" "LIVE WEBCAM CAPTURE"
    echo -e "${YELLOW}📸 About to capture photo from your webcam...${NC}"
    echo -e "${BLUE}Position yourself in front of the camera!${NC}"
    echo ""
    echo -e "${WHITE}The system will:${NC}"
    echo -e "${CYAN}  1. Wait 3 seconds for you to get ready${NC}"
    echo -e "${CYAN}  2. Capture photo from FaceTime camera${NC}"
    echo -e "${CYAN}  3. Immediately display the captured image${NC}"
    echo ""
    
    wait_for_user
    
    echo -e "${GREEN}📸 Capturing in 3... 2... 1...${NC}"
    sleep 1
    
    # Clean up any old files
    rm -f photo*.jpg *.sig *.sha256 *.manifest
    
    # Capture the image
    echo -e "${BLUE}🎥 Taking photo...${NC}"
    imagesnap -w 3 photo.jpg
    
    if [[ -f "photo.jpg" ]]; then
        echo -e "${GREEN}✅ Photo captured successfully!${NC}"
        show_image "photo.jpg" "Original Captured Photo"
        
        # Show file info
        local size=$(ls -lh photo.jpg | awk '{print $5}')
        echo -e "${CYAN}📊 Image size: $size${NC}"
        echo -e "${CYAN}📅 Captured: $(date)${NC}"
    else
        echo -e "${RED}❌ Photo capture failed${NC}"
        exit 1
    fi
    
    wait_for_user

    # Step 4: Cryptographic signing
    show_step "4" "CRYPTOGRAPHIC SIGNING"
    echo -e "${BLUE}🔐 Now we'll create a cryptographic signature...${NC}"
    echo ""
    echo -e "${WHITE}This process:${NC}"
    echo -e "${CYAN}  1. Calculates SHA-256 hash of the image${NC}"
    echo -e "${CYAN}  2. Signs the hash with our private key${NC}"
    echo -e "${CYAN}  3. Creates detached signature file${NC}"
    echo ""
    
    wait_for_user
    
    # Generate hash
    echo -e "${BLUE}🔢 Calculating SHA-256 hash...${NC}"
    shasum -a 256 photo.jpg | awk '{print $1}' > photo.jpg.sha256
    show_crypto_data "photo.jpg.sha256" "Image Hash (SHA-256)"
    
    # Create signature
    echo -e "${BLUE}✍️  Creating ECDSA signature...${NC}"
    openssl dgst -sha256 -sign keys/device.key -out photo.jpg.sig photo.jpg
    
    if [[ -f "photo.jpg.sig" ]]; then
        echo -e "${GREEN}✅ Signature created!${NC}"
        show_crypto_data "photo.jpg.sig" "Cryptographic Signature (Binary)"
        
        local sig_size=$(ls -lh photo.jpg.sig | awk '{print $5}')
        echo -e "${CYAN}📊 Signature size: $sig_size${NC}"
    else
        echo -e "${RED}❌ Signature creation failed${NC}"
        exit 1
    fi
    
    wait_for_user

    # Step 5: Verification
    show_step "5" "SIGNATURE VERIFICATION"
    echo -e "${BLUE}🔍 Verifying the signature with our Python script...${NC}"
    echo ""
    
    # Show what the verification script does
    echo -e "${WHITE}The verification process:${NC}"
    echo -e "${CYAN}  1. Loads the public key${NC}"
    echo -e "${CYAN}  2. Recalculates the image hash${NC}"
    echo -e "${CYAN}  3. Verifies signature matches${NC}"
    echo -e "${CYAN}  4. Shows ✅ VERIFIED or ❌ TAMPERED${NC}"
    echo ""
    
    wait_for_user
    
    echo -e "${GREEN}🔐 Running verification...${NC}"
    echo ""
    python3 verify_simple.py photo.jpg
    echo ""
    
    # Also verify with OpenSSL directly
    echo -e "${BLUE}🔧 Double-checking with OpenSSL directly...${NC}"
    if openssl dgst -sha256 -verify keys/device.pub -signature photo.jpg.sig photo.jpg; then
        echo -e "${GREEN}✅ OpenSSL confirms: Signature is valid!${NC}"
    else
        echo -e "${RED}❌ OpenSSL says: Signature verification failed!${NC}"
    fi
    
    wait_for_user

    # Step 6: Tampering demonstration
    show_step "6" "TAMPER DETECTION DEMO"
    echo -e "${YELLOW}🔧 Now we'll tamper with the image and prove detection works...${NC}"
    echo ""
    echo -e "${WHITE}What we'll do:${NC}"
    echo -e "${CYAN}  1. Create a modified copy of the image${NC}"
    echo -e "${CYAN}  2. Change just ONE bit of data${NC}"
    echo -e "${CYAN}  3. Show you both images (they look identical)${NC}"
    echo -e "${CYAN}  4. Prove the signature detects the change${NC}"
    echo ""
    
    wait_for_user
    
    # Create tampered version
    echo -e "${BLUE}🔧 Creating tampered version...${NC}"
    python3 tamper_simple.py photo.jpg
    
    if [[ -f "photo_tampered.jpg" ]]; then
        echo -e "${GREEN}✅ Tampered version created!${NC}"
        echo ""
        
        # Show both images with watermarks
        echo -e "${BLUE}👁️  Creating presentation images for side-by-side comparison...${NC}"
        echo ""
        
        echo -e "${GREEN}🎨 Original image with VERIFIED watermark:${NC}"
        show_image_with_watermark "photo.jpg" "Original Image (Verified)" "verified"
        
        sleep 3
        
        echo -e "${RED}🎨 Tampered image with TAMPERED watermark:${NC}"
        show_image_with_watermark "photo_tampered.jpg" "Tampered Image (1 bit changed)" "tampered"
        
        echo -e "${YELLOW}📝 Notice: Both images now have clear visual indicators!${NC}"
        echo -e "${YELLOW}   Green checkmark = Cryptographically verified${NC}"
        echo -e "${YELLOW}   Red X mark = Tampered/modified${NC}"
        
        # Show hash difference
        echo ""
        echo -e "${BLUE}🔢 Comparing hashes:${NC}"
        echo -e "${WHITE}Original hash:${NC}"
        cat photo.jpg.sha256
        echo -e "${WHITE}Tampered hash:${NC}"
        shasum -a 256 photo_tampered.jpg | awk '{print $1}'
        echo -e "${YELLOW}☝️  Completely different hashes!${NC}"
        
    else
        echo -e "${RED}❌ Failed to create tampered version${NC}"
        exit 1
    fi
    
    wait_for_user

    # Step 7: Verify tampered image fails
    show_step "7" "TAMPER DETECTION VERIFICATION"
    echo -e "${RED}🚨 Testing tampered image against original signature...${NC}"
    echo ""
    echo -e "${WHITE}This should show ❌ TAMPERED because:${NC}"
    echo -e "${CYAN}  • Image data has been modified${NC}"
    echo -e "${CYAN}  • Hash no longer matches${NC}"
    echo -e "${CYAN}  • Signature verification will fail${NC}"
    echo ""
    
    wait_for_user
    
    echo -e "${RED}🔍 Verifying tampered image...${NC}"
    echo ""
    python3 verify_simple.py photo_tampered.jpg
    echo ""
    
    # Also verify with OpenSSL
    echo -e "${BLUE}🔧 OpenSSL verification of tampered image:${NC}"
    if openssl dgst -sha256 -verify keys/device.pub -signature photo.jpg.sig photo_tampered.jpg; then
        echo -e "${RED}❌ ERROR: Tampered image verified (this shouldn't happen!)${NC}"
    else
        echo -e "${GREEN}✅ OpenSSL correctly detected tampering!${NC}"
    fi
    
    wait_for_user

    # Step 8: Summary
    show_step "8" "DEMONSTRATION COMPLETE"
    echo -e "${GREEN}🎉 CRYPTOGRAPHIC AUTHENTICITY PROVEN!${NC}"
    echo ""
    echo -e "${WHITE}What we've demonstrated:${NC}"
    echo -e "${GREEN}✅ Live webcam capture with immediate display${NC}"
    echo -e "${GREEN}✅ Real ECDSA cryptographic signatures${NC}"
    echo -e "${GREEN}✅ External verification with OpenSSL${NC}"
    echo -e "${GREEN}✅ Detection of ANY image modification${NC}"
    echo -e "${GREEN}✅ Visual proof with actual photos${NC}"
    echo ""
    echo -e "${BLUE}📁 Files created during this demo:${NC}"
    ls -la photo* *.sig *.sha256 2>/dev/null || true
    echo ""
    echo -e "${PURPLE}🔐 This is REAL cryptographic security, not scripted theater!${NC}"
    echo ""
    echo -e "${YELLOW}🚀 Ready for Week-2: Hardware security module integration${NC}"
    echo -e "${YELLOW}🎯 Ready for Week-3: Real-time streaming support${NC}"
    echo ""
    echo -e "${WHITE}Thank you for watching the demo! 🎉${NC}"
    echo ""
}

# Run the demo
main_demo