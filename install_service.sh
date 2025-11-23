#!/bin/bash
# Install WiiFitBoardBit as a systemd service

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SERVICE_FILE="wiifitboardbit.service"
SERVICE_NAME="wiifitboardbit.service"

echo "Installing WiiFitBoardBit systemd service..."

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run with sudo: sudo ./install_service.sh"
    exit 1
fi

# Update WorkingDirectory in service file to current directory
sed -i "s|WorkingDirectory=.*|WorkingDirectory=$SCRIPT_DIR|g" "$SERVICE_FILE"
sed -i "s|ExecStart=.*|ExecStart=/usr/bin/python2 $SCRIPT_DIR/main.py|g" "$SERVICE_FILE"

# Copy service file
echo "Copying service file to /etc/systemd/system/..."
cp "$SERVICE_FILE" "/etc/systemd/system/$SERVICE_NAME"

# Reload systemd
echo "Reloading systemd daemon..."
systemctl daemon-reload

# Enable service
echo "Enabling service to start on boot..."
systemctl enable "$SERVICE_NAME"

# Ask if user wants to start now
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
echo "Installation complete!"
echo ""
echo "Useful commands:"
echo "  Start service:   sudo systemctl start $SERVICE_NAME"
echo "  Stop service:    sudo systemctl stop $SERVICE_NAME"
echo "  Restart service: sudo systemctl restart $SERVICE_NAME"
echo "  View status:     sudo systemctl status $SERVICE_NAME"
echo "  View logs:       sudo journalctl -u $SERVICE_NAME -f"
echo "  Disable service: sudo systemctl disable $SERVICE_NAME"
