# Headless Server Setup Guide

This guide will help you set up WiiFitBoardBit as a background service that runs automatically on your Raspberry Pi.

## Quick Setup

1. **Navigate to your WiiFitBoardBit directory:**
   ```bash
   cd /path/to/WiiFitBoardBit
   ```

2. **Install the service:**
   ```bash
   sudo ./install_service.sh
   ```

3. **That's it!** The service is now running and will start automatically on boot.

The installer will automatically detect your installation directory and user, and configure the service with the correct paths.

## Managing the Service

### Check Status
```bash
sudo systemctl status wiifitboardbit
```

### Start/Stop/Restart
```bash
sudo systemctl start wiifitboardbit   # Start the service
sudo systemctl stop wiifitboardbit    # Stop the service
sudo systemctl restart wiifitboardbit # Restart the service
```

### View Logs
```bash
# View live logs (follow mode)
tail -f /path/to/WiiFitBoardBit/log.txt

# View last 50 lines
tail -n 50 /path/to/WiiFitBoardBit/log.txt

# View all logs
cat /path/to/WiiFitBoardBit/log.txt
```

**Note:** Replace `/path/to/WiiFitBoardBit` with your actual installation directory (e.g., `~/git/WiiFitBoardBit`).

### Disable Auto-Start
If you want to stop the service from starting automatically on boot:
```bash
sudo systemctl disable wiifitboardbit
```

To re-enable:
```bash
sudo systemctl enable wiifitboardbit
```

## How It Works

The systemd service:
- **Starts automatically** when the Raspberry Pi boots
- **Runs in the background** (no terminal needed)
- **Restarts automatically** if it crashes (waits 10 seconds before restarting)
- **Logs everything** to `log.txt` in the project directory
- **Requires root** to access Bluetooth

## Updating the Software

When you pull new changes from git:

```bash
cd /path/to/WiiFitBoardBit
git pull

# Restart the service to apply changes
sudo systemctl restart wiifitboardbit
```

## Troubleshooting

### Service won't start
Check the status for error messages:
```bash
sudo systemctl status wiifitboardbit -l --no-pager
```

Check the logs:
```bash
tail -n 100 /path/to/WiiFitBoardBit/log.txt
```

### Service keeps restarting
The service is configured to restart automatically if it crashes. Check the logs to see what's causing the crashes.

### Remove the service completely
```bash
sudo systemctl stop wiifitboardbit
sudo systemctl disable wiifitboardbit
sudo rm /etc/systemd/system/wiifitboardbit.service
sudo systemctl daemon-reload
```

## Testing Before Going Headless

Before relying on the service, test that everything works:

1. **Stop the service:**
   ```bash
   sudo systemctl stop wiifitboardbit
   ```

2. **Run manually to verify:**
   ```bash
   cd /path/to/WiiFitBoardBit
   ./run.sh
   ```

3. **Test weight measurement:**
   - Press the button on the Wii Balance Board
   - Step on the board
   - Wait for weight to be logged
   - Check that it syncs to Fitbit

4. **If everything works, start the service:**
   ```bash
   sudo systemctl start wiifitboardbit
   ```

## Normal Operation

Once set up as a headless service:

1. **Power on** your Raspberry Pi
2. **Wait ~30 seconds** for the service to start
3. **Press the button** on the Wii Balance Board (small button on bottom)
4. **Step on the board** and wait
5. **Done!** Your weight is logged and synced to Fitbit

No SSH connection or terminal needed!
