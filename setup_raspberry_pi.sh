#!/bin/bash
# WiiFitBoardBit Raspberry Pi Setup Script
# This script automates the installation of dependencies for the Wii Balance Board scale

set -e  # Exit on error

echo "=========================================="
echo "WiiFitBoardBit Raspberry Pi Setup"
echo "=========================================="
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on Raspberry Pi/Debian-based system
if ! command -v apt-get &> /dev/null; then
    print_error "This script requires a Debian-based system (apt-get not found)"
    exit 1
fi

# Update package list
print_info "Updating package list..."
sudo apt-get update

# Install base dependencies
print_info "Installing base dependencies (Python 2, Bluez, build tools)..."
sudo apt-get install -y \
    python2 \
    python-pip \
    bluez \
    build-essential \
    git \
    autoconf \
    libtool \
    libudev-dev \
    libncurses5-dev \
    swig \
    python-dev \
    python-numpy \
    libcairo2-dev \
    libgirepository1.0-dev \
    libssl-dev \
    libdbus-glib-1-dev \
    python-dbus \
    python-oauthlib

# Create directory for building XWiimote
BUILD_DIR="/tmp/wiimote_build"
print_info "Creating build directory: $BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Install XWiimote
if [ ! -d "/usr/local/include/xwiimote.h" ] && [ ! -f "/usr/include/xwiimote.h" ]; then
    print_info "Installing XWiimote..."

    if [ -d "xwiimote" ]; then
        rm -rf xwiimote
    fi

    git clone https://github.com/dvdhrm/xwiimote.git
    cd xwiimote
    ./autogen.sh --prefix=/usr
    make
    sudo make install
    cd ..

    print_info "XWiimote installed successfully"
else
    print_warning "XWiimote appears to be already installed, skipping..."
fi

# Install XWiimote-bindings
if ! python2 -c "import xwiimote" &> /dev/null; then
    print_info "Installing XWiimote Python bindings..."

    if [ -d "xwiimote-bindings" ]; then
        rm -rf xwiimote-bindings
    fi

    git clone https://github.com/dvdhrm/xwiimote-bindings.git
    cd xwiimote-bindings
    ./autogen.sh --prefix=/usr
    make
    sudo make install
    cd ..

    # Update library cache
    sudo ldconfig

    print_info "XWiimote-bindings installed successfully"
else
    print_warning "XWiimote-bindings appear to be already installed, skipping..."
fi

# Return to project directory
cd - > /dev/null

# Install Python dependencies
print_info "Installing Python dependencies from requirements.txt..."
pip2 install --user -r requirements.txt || {
    print_warning "Some pip packages failed, trying with sudo..."
    sudo pip2 install -r requirements.txt
}

# Create data directory if it doesn't exist
if [ ! -d "data" ]; then
    print_info "Creating data directory..."
    mkdir -p data
fi

# Verify installations
print_info "Verifying installations..."

# Check Python 2
if python2 --version &> /dev/null; then
    print_info "✓ Python 2 installed: $(python2 --version 2>&1)"
else
    print_error "✗ Python 2 not found"
    exit 1
fi

# Check Bluez
if bluetoothctl --version &> /dev/null; then
    print_info "✓ Bluez installed: $(bluetoothctl --version 2>&1 | head -n 1)"
else
    print_error "✗ Bluez not found"
    exit 1
fi

# Check XWiimote Python bindings
if python2 -c "import xwiimote" &> /dev/null; then
    print_info "✓ XWiimote Python bindings installed"
else
    print_error "✗ XWiimote Python bindings not found"
    print_warning "You may need to set LD_LIBRARY_PATH and PYTHONPATH:"
    print_warning "export LD_LIBRARY_PATH=/usr/lib"
    print_warning "export PYTHONPATH=/usr/lib/python2.7/site-packages"
fi

echo ""
echo "=========================================="
print_info "Installation complete!"
echo "=========================================="
echo ""
print_info "Next steps:"
echo "  1. Pair your Wii Balance Board (see SETUP_GUIDE.md)"
echo "  2. Configure config.py (optional: set up Fitbit sync)"
echo "  3. Run: sudo python2 main.py"
echo ""
print_warning "If you encounter library path issues, run with:"
echo "  sudo LD_LIBRARY_PATH=/usr/lib PYTHONPATH=/usr/lib/python2.7/site-packages python2 main.py"
echo ""
