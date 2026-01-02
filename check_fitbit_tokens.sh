#!/bin/bash
# Check Fitbit OAuth token storage status

echo "========================================"
echo "Fitbit OAuth Token Diagnostic"
echo "========================================"
echo ""

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
AUTH_DATA_DIR="$SCRIPT_DIR/fitbit_sync/auth_data"

echo "Project directory: $SCRIPT_DIR"
echo "Auth data directory: $AUTH_DATA_DIR"
echo ""

# Check if auth_data directory exists
if [ ! -d "$AUTH_DATA_DIR" ]; then
    echo "❌ Auth data directory does NOT exist"
    echo "   This is created automatically when you first authorize with Fitbit"
else
    echo "✅ Auth data directory exists"
    echo ""

    # Check permissions
    echo "Directory permissions:"
    ls -ld "$AUTH_DATA_DIR"
    echo ""

    # Check for token files
    echo "Token files:"
    if ls "$AUTH_DATA_DIR"/*.json 1> /dev/null 2>&1; then
        ls -lh "$AUTH_DATA_DIR"/*.json
        echo ""

        # Check if files are readable
        for file in "$AUTH_DATA_DIR"/*.json; do
            if [ -r "$file" ]; then
                echo "✅ $(basename $file) is readable"
            else
                echo "❌ $(basename $file) is NOT readable"
            fi
        done
    else
        echo "❌ No token files found (*.json)"
        echo "   You need to authorize at http://YOUR_PI_IP:8080/"
    fi
fi

echo ""
echo "========================================"
echo "Quick Fix Commands"
echo "========================================"
echo ""
echo "If files exist but have wrong permissions, run:"
echo "  sudo chown -R \$USER:$USER $AUTH_DATA_DIR"
echo "  chmod -R 755 $AUTH_DATA_DIR"
echo ""
