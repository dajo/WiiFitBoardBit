#!/bin/bash
# Install WiiFitBoardBit as a systemd service for automatic startup

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SERVICE_FILE="wiifitboardbit.service"
SERVICE_NAME="wiifitboardbit.service"

echo "=========================================="
echo "WiiFitBoardBit Service Installer"
echo "=========================================="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run with sudo: sudo ./install_service.sh"
    exit 1
fi

# Check if service file exists
if [ ! -f "$SERVICE_FILE" ]; then
    echo "Error: Service file not found: $SERVICE_FILE"
    exit 1
fi

echo "Installing WiiFitBoardBit as a system service..."
echo "Installation directory: $SCRIPT_DIR"
echo ""

# Get the current user who invoked sudo (for finding their site-packages)
ACTUAL_USER="${SUDO_USER:-$USER}"
USER_HOME=$(eval echo ~$ACTUAL_USER)
USER_SITE_PACKAGES="$USER_HOME/.local/lib/python2.7/site-packages"

echo "Detected user: $ACTUAL_USER"
echo "User home: $USER_HOME"
echo ""

# Create a temporary service file with the correct paths
echo "1. Generating service file with correct paths..."
TEMP_SERVICE=$(mktemp)
sed -e "s|/path/to/WiiFitBoardBit|$SCRIPT_DIR|g" \
    -e "s|/home/user/\.local/lib/python2\.7/site-packages|$USER_SITE_PACKAGES|g" \
    "$SERVICE_FILE" > "$TEMP_SERVICE"

# Copy the customized service file to systemd directory
echo "2. Copying service file to /etc/systemd/system/..."
cp "$TEMP_SERVICE" "/etc/systemd/system/$SERVICE_NAME"
rm "$TEMP_SERVICE"

# Reload systemd
echo "3. Reloading systemd daemon..."
systemctl daemon-reload

# Enable the service to start on boot
echo "4. Enabling service to start on boot..."
systemctl enable "$SERVICE_NAME"

# Ask if user wants to start now
echo ""
read -p "Do you want to start the service now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Starting service..."
    systemctl start "$SERVICE_NAME"
    sleep 2
    echo ""
    echo "Service status:"
    systemctl status "$SERVICE_NAME" --no-pager
fi

echo ""
echo "=========================================="
echo "Installation Complete!"
echo "=========================================="
echo ""
echo "The WiiFitBoardBit service will start automatically on boot."
echo ""
echo "Useful commands:"
echo "  sudo systemctl status wiifitboardbit    # Check service status"
echo "  sudo systemctl stop wiifitboardbit      # Stop the service"
echo "  sudo systemctl start wiifitboardbit     # Start the service"
echo "  sudo systemctl restart wiifitboardbit   # Restart the service"
echo "  tail -f $SCRIPT_DIR/log.txt             # View live logs"
echo "  sudo systemctl disable wiifitboardbit   # Disable auto-start"
echo ""
