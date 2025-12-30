#!/bin/bash
# WiiFitBoardBit Runner Script
# This script sets the required environment variables and runs the program

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Set Python path for XWiimote bindings
export PYTHONPATH=/usr/lib/python2.7/site-packages:/usr/local/lib/python2.7/site-packages
export LD_LIBRARY_PATH=/usr/lib:/usr/local/lib

echo "Starting WiiFitBoardBit..."
echo "Press Ctrl+C to stop"
echo ""

# Run with sudo to access Bluetooth
sudo -E PYTHONPATH="$PYTHONPATH" LD_LIBRARY_PATH="$LD_LIBRARY_PATH" python2 main.py
