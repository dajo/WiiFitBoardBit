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

# Detect OS version
print_info "Detecting OS version..."
OS_VERSION=$(grep VERSION_CODENAME /etc/os-release | cut -d'=' -f2)
print_info "Detected: Debian/Raspbian $OS_VERSION"

# Update package list
print_info "Updating package list..."
sudo apt-get update

# Install base dependencies (non-Python packages first)
print_info "Installing base dependencies (Bluez, build tools)..."
sudo apt-get install -y \
    bluez \
    build-essential \
    git \
    autoconf \
    libtool \
    libudev-dev \
    libncurses5-dev \
    swig \
    libcairo2-dev \
    libgirepository1.0-dev \
    libssl-dev \
    libdbus-glib-1-dev \
    curl

# Install Python 2.7 (handling different OS versions)
print_info "Installing Python 2.7..."

if [[ "$OS_VERSION" == "bookworm" ]] || [[ "$OS_VERSION" == "bullseye" ]]; then
    print_warning "Newer OS detected - Python 2 not in default repos, installing from available packages..."

    # Try to install python2.7 and related packages
    sudo apt-get install -y python2.7 python2.7-dev || {
        print_error "Python 2.7 not available in repositories."
        print_info "Attempting to install from deadsnakes or alternative source..."

        # For newer systems, we may need to compile or use alternative repos
        print_warning "You may need to compile Python 2.7 from source or your system may already have it."
    }

    # Create python2 symlink if it doesn't exist
    if ! command -v python2 &> /dev/null && command -v python2.7 &> /dev/null; then
        print_info "Creating python2 symlink..."
        sudo ln -sf /usr/bin/python2.7 /usr/bin/python2
    fi

    # Install pip2 manually if not available
    if ! command -v pip2 &> /dev/null; then
        print_info "Installing pip2 manually..."
        curl https://bootstrap.pypa.io/pip/2.7/get-pip.py -o /tmp/get-pip.py
        sudo python2.7 /tmp/get-pip.py
        rm /tmp/get-pip.py
    fi

else
    # Older OS versions (Buster and earlier) have Python 2 in repos
    print_info "Installing Python 2 from repositories..."
    sudo apt-get install -y \
        python2 \
        python-pip \
        python-dev
fi

# Install Python 2 system packages that are available
print_info "Installing available Python 2 system packages..."
sudo apt-get install -y \
    python-dbus \
    python-numpy \
    python3-numpy || print_warning "Some Python packages not available, will install via pip later"

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

# First try to install dbus-python if not available as system package
if ! python2 -c "import dbus" &> /dev/null; then
    print_info "Installing dbus-python via pip..."
    sudo pip2 install dbus-python || print_warning "dbus-python installation failed, may need system package"
fi

# Install other requirements
if command -v pip2 &> /dev/null; then
    pip2 install --user -r requirements.txt || {
        print_warning "Some pip packages failed, trying with sudo..."
        sudo pip2 install -r requirements.txt || print_warning "Some packages may have failed to install"
    }
else
    print_error "pip2 not found! Cannot install Python dependencies."
    print_info "Please install pip2 manually and run: pip2 install -r requirements.txt"
fi

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
