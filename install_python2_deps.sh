#!/bin/bash
# Script to install Python 2 dependencies for WiiFitBoardBit

set -e

echo "=========================================="
echo "Installing Python 2 Dependencies"
echo "=========================================="

# Check if python2.7 exists
if ! command -v python2.7 &> /dev/null; then
    echo "Error: python2.7 not found. Please run setup_raspberry_pi.sh first."
    exit 1
fi

echo "Python 2.7 found: $(python2.7 --version)"

# Install pip for Python 2.7 if not already installed
if ! python2.7 -m pip --version &> /dev/null; then
    echo "Installing pip for Python 2.7..."
    curl https://bootstrap.pypa.io/pip/2.7/get-pip.py -o /tmp/get-pip.py
    sudo python2.7 /tmp/get-pip.py
    rm /tmp/get-pip.py
else
    echo "pip already installed: $(python2.7 -m pip --version)"
fi

# Install dependencies from requirements.txt
echo ""
echo "Installing Python dependencies from requirements.txt..."
echo ""

cd "$(dirname "$0")"

# Try user install first, then system-wide if needed
if python2.7 -m pip install --user -r requirements.txt; then
    echo "Dependencies installed successfully (user mode)"
else
    echo "User install failed, trying system-wide install..."
    sudo python2.7 -m pip install -r requirements.txt
fi

echo ""
echo "=========================================="
echo "Installation complete!"
echo "=========================================="
echo ""
echo "You can now run:"
echo "  python2 delete_fitbit_weight.py"
echo ""
