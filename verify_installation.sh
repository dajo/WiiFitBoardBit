#!/bin/bash
# Verify Python 2 and Dependencies Installation
# Run this to check what's already installed on your system

echo "=========================================="
echo "WiiFitBoardBit Installation Verification"
echo "=========================================="
echo ""

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_check() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $2"
    else
        echo -e "${RED}✗${NC} $2"
    fi
}

echo "=== System Information ==="
echo "OS Version: $(grep PRETTY_NAME /etc/os-release | cut -d'"' -f2)"
echo "Kernel: $(uname -r)"
echo ""

echo "=== Python Versions ==="
if command -v python &> /dev/null; then
    echo "python:     $(python --version 2>&1)"
else
    echo "python:     Not found"
fi

if command -v python2 &> /dev/null; then
    echo "python2:    $(python2 --version 2>&1)"
else
    echo "python2:    Not found"
fi

if command -v python2.7 &> /dev/null; then
    echo "python2.7:  $(python2.7 --version 2>&1)"
else
    echo "python2.7:  Not found"
fi

if command -v python3 &> /dev/null; then
    echo "python3:    $(python3 --version 2>&1)"
else
    echo "python3:    Not found"
fi
echo ""

echo "=== Python Package Managers ==="
if command -v pip &> /dev/null; then
    echo "pip:        $(pip --version 2>&1 | head -n1)"
else
    echo "pip:        Not found"
fi

if command -v pip2 &> /dev/null; then
    echo "pip2:       $(pip2 --version 2>&1 | head -n1)"
else
    echo "pip2:       Not found"
fi

if command -v pip3 &> /dev/null; then
    echo "pip3:       $(pip3 --version 2>&1 | head -n1)"
else
    echo "pip3:       Not found"
fi
echo ""

echo "=== Required System Packages ==="
check_package() {
    if dpkg -l | grep -q "^ii  $1 "; then
        echo -e "${GREEN}✓${NC} $1 (installed)"
    else
        echo -e "${RED}✗${NC} $1 (not installed)"
    fi
}

check_package "bluez"
check_package "build-essential"
check_package "git"
check_package "python2.7"
check_package "python2.7-dev"
check_package "libdbus-glib-1-dev"
check_package "libudev-dev"
check_package "swig"
echo ""

echo "=== Python 2 Module Availability ==="
check_python_module() {
    if python2 -c "import $1" &> /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} $1"
    else
        echo -e "${RED}✗${NC} $1"
    fi
}

if command -v python2 &> /dev/null; then
    check_python_module "xwiimote"
    check_python_module "dbus"
    check_python_module "numpy"
    check_python_module "six"
    check_python_module "requests"
    check_python_module "flask"
    check_python_module "requests_oauthlib"
else
    echo -e "${RED}Python 2 not available - cannot check modules${NC}"
fi
echo ""

echo "=== XWiimote Installation ==="
if [ -f "/usr/include/xwiimote.h" ] || [ -f "/usr/local/include/xwiimote.h" ]; then
    echo -e "${GREEN}✓${NC} XWiimote header files found"
else
    echo -e "${RED}✗${NC} XWiimote header files not found"
fi

if [ -f "/usr/lib/libxwiimote.so" ] || [ -f "/usr/local/lib/libxwiimote.so" ] || find /usr -name "libxwiimote.so*" 2>/dev/null | grep -q .; then
    echo -e "${GREEN}✓${NC} XWiimote library found"
    find /usr -name "libxwiimote.so*" 2>/dev/null | head -n3
else
    echo -e "${RED}✗${NC} XWiimote library not found"
fi

if find /usr -name "_xwiimote.so" 2>/dev/null | grep -q .; then
    echo -e "${GREEN}✓${NC} XWiimote Python bindings found"
    find /usr -name "_xwiimote.so" 2>/dev/null | head -n3
else
    echo -e "${RED}✗${NC} XWiimote Python bindings not found"
fi
echo ""

echo "=== Bluetooth Status ==="
if systemctl is-active --quiet bluetooth; then
    echo -e "${GREEN}✓${NC} Bluetooth service is running"
else
    echo -e "${RED}✗${NC} Bluetooth service is not running"
fi

if command -v bluetoothctl &> /dev/null; then
    echo -e "${GREEN}✓${NC} bluetoothctl available: $(bluetoothctl --version 2>&1 | head -n1)"
else
    echo -e "${RED}✗${NC} bluetoothctl not available"
fi
echo ""

echo "=== File Permissions ==="
if [ -d "data" ]; then
    echo -e "${GREEN}✓${NC} data directory exists"
    ls -ld data
else
    echo -e "${YELLOW}!${NC} data directory does not exist (will be created on first run)"
fi

if [ -f "config.py" ]; then
    echo -e "${GREEN}✓${NC} config.py exists"
else
    echo -e "${RED}✗${NC} config.py not found"
fi
echo ""

echo "=== Summary ==="
MISSING=0

if ! command -v python2 &> /dev/null; then
    echo -e "${YELLOW}[NEEDED]${NC} Python 2"
    MISSING=1
fi

if ! command -v pip2 &> /dev/null; then
    echo -e "${YELLOW}[NEEDED]${NC} pip2"
    MISSING=1
fi

if ! python2 -c "import xwiimote" &> /dev/null 2>&1; then
    echo -e "${YELLOW}[NEEDED]${NC} XWiimote Python bindings"
    MISSING=1
fi

if ! python2 -c "import dbus" &> /dev/null 2>&1; then
    echo -e "${YELLOW}[NEEDED]${NC} Python dbus module"
    MISSING=1
fi

if [ $MISSING -eq 0 ]; then
    echo -e "${GREEN}All core dependencies appear to be installed!${NC}"
    echo ""
    echo "You should be able to run:"
    echo "  sudo python2 main.py"
else
    echo ""
    echo "Some dependencies are missing. Options:"
    echo "  1. Run ./setup_raspberry_pi.sh (automated)"
    echo "  2. Install manually (see manual_install.md)"
fi
echo ""
