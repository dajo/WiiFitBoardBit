# Raspberry Pi Setup Guide for WiiFitBoardBit

This guide will walk you through setting up your Raspberry Pi to use the Wii Balance Board as a smart scale that syncs weight data to Fitbit.

## Prerequisites

- Raspberry Pi (tested on Pi 4, but should work on Pi 3/Zero W with Bluetooth)
- Wii Balance Board
- Raspberry Pi OS (Raspbian) installed
- Internet connection
- SSH or direct access to the Pi

---

## Quick Start (Automated Setup)

### Step 1: Run the Setup Script

```bash
cd /path/to/WiiFitBoardBit
chmod +x setup_raspberry_pi.sh
./setup_raspberry_pi.sh
```

This script will automatically install:
- Python 2 and pip
- Bluez (Bluetooth stack)
- Build tools and dependencies
- XWiimote and XWiimote-bindings
- Python packages from requirements.txt

The installation may take 15-30 minutes depending on your Pi model.

---

## Step 2: Pair Your Wii Balance Board

This is a **one-time setup** that allows you to use the front button on the Wii Balance Board (instead of the red sync button) for future use.

### 2.1 Open Bluetooth Controller

```bash
sudo bluetoothctl
```

### 2.2 Configure Bluetooth

Run these commands in the bluetoothctl prompt:

```
power on
agent on
scan on
```

### 2.3 Press the Red Sync Button

Open the battery compartment on the bottom of your Wii Balance Board and press the small red **SYNC** button. The blue LED on the board should start blinking.

Watch the bluetoothctl output for a device like:

```
[NEW] Device XX:XX:XX:XX:XX:XX Nintendo RVL-WBC-01
```

**Note the MAC address (XX:XX:XX:XX:XX:XX)** - you'll need it for the next steps.

### 2.4 Pair, Connect, and Trust

Replace `XX:XX:XX:XX:XX:XX` with your board's MAC address:

```
pair XX:XX:XX:XX:XX:XX
```

Wait for "Pairing successful", then immediately run:

```
connect XX:XX:XX:XX:XX:XX
```

Wait for "Connection successful", then:

```
trust XX:XX:XX:XX:XX:XX
```

### 2.5 Disconnect and Exit

```
disconnect XX:XX:XX:XX:XX:XX
scan off
exit
```

### 2.6 (Optional) Save MAC Address

Edit `config.py` and set:

```python
BALANCE_BOARD_MAC = "XX:XX:XX:XX:XX:XX"
```

This makes the program connect faster.

---

## Step 3: Configure Fitbit Sync (Optional)

If you want to sync weight data to Fitbit:

### 3.1 Create a Fitbit Developer App

1. Go to https://dev.fitbit.com/apps
2. Click "Register a new app"
3. Fill in the form:
   - **Application Name**: WiiFitBoardBit (or your choice)
   - **Application Website URL**: Your GitHub or any URL
   - **Organization**: N/A (or your name)
   - **Organization Website**: Your GitHub or any URL
   - **Terms of Service URL**: https://www.fitbit.com/legal/terms-of-service
   - **Privacy Policy URL**: https://www.fitbit.com/legal/privacy-policy
   - **OAuth 2.0 Application Type**: **Personal**
   - **Redirect URL**: `http://127.0.0.1:8080/fitbit_auth_redirect`
   - **Default Access Type**: **Read & Write**

4. Click "Save" and note your **Client ID** and **Client Secret**

### 3.2 Update config.py

Edit `config.py`:

```python
FITBIT_SYNC_ENABLED = True
FITBIT_CLIENT_ID = "YOUR_CLIENT_ID"
FITBIT_CLIENT_SECRET = "YOUR_CLIENT_SECRET"
```

### 3.3 Authorize Your Fitbit Account

After starting the program (see Step 4), open a browser and go to:

```
http://YOUR_PI_IP_ADDRESS:8080/
```

For example: `http://192.168.1.100:8080/`

Follow the prompts to authorize with your Fitbit account.

---

## Step 4: Run WiiFitBoardBit

### Basic Run

```bash
cd /path/to/WiiFitBoardBit
sudo python2 main.py
```

### If You Get Library Path Errors

```bash
sudo LD_LIBRARY_PATH=/usr/lib PYTHONPATH=/usr/lib/python2.7/site-packages python2 main.py
```

### Test It

1. Press the **front button** on the Wii Balance Board (NOT the red sync button)
2. The blue LED should turn on
3. Step on the board
4. Wait for the measurement to stabilize (~5 seconds)
5. Step off
6. The LED should turn off and your weight should be logged

Check `data/weight.csv` for the logged data.

---

## Step 5: Auto-Start on Boot (Optional)

To run WiiFitBoardBit automatically when your Pi boots:

### 5.1 Install the Systemd Service

```bash
sudo cp wiifitboardbit.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable wiifitboardbit.service
sudo systemctl start wiifitboardbit.service
```

### 5.2 Check Status

```bash
sudo systemctl status wiifitboardbit.service
```

### 5.3 View Logs

```bash
# System logs
sudo journalctl -u wiifitboardbit.service -f

# Application logs
tail -f log.txt
```

---

## Troubleshooting

### Wii Balance Board Won't Connect

1. **Check Bluetooth is enabled:**
   ```bash
   sudo systemctl status bluetooth
   ```

2. **Check if board is paired:**
   ```bash
   sudo bluetoothctl
   devices
   ```
   Look for `Nintendo RVL-WBC-01`

3. **Try re-pairing** (follow Step 2 again)

4. **Check battery** - Replace batteries in the board if LED is dim

### XWiimote Import Error

If you get `ImportError: No module named xwiimote`:

```bash
export LD_LIBRARY_PATH=/usr/lib
export PYTHONPATH=/usr/lib/python2.7/site-packages
sudo -E python2 main.py
```

Or update your systemd service to include these environment variables.

### Permission Denied Errors

Make sure to run with `sudo`:

```bash
sudo python2 main.py
```

### Fitbit Sync Not Working

1. **Check config.py** - Make sure `FITBIT_SYNC_ENABLED = True`
2. **Check credentials** - Verify CLIENT_ID and CLIENT_SECRET
3. **Check authorization** - Go to `http://YOUR_PI_IP:8080/` and authorize
4. **Check logs** - Look in `log.txt` for errors

### No Weight Data Logged

1. **Check CSV file exists:** `data/weight.csv`
2. **Check file permissions:**
   ```bash
   ls -la data/weight.csv
   ```
3. **Check logs:** `cat log.txt`

---

## File Locations

- **Weight data**: `data/weight.csv`
- **Application logs**: `log.txt`
- **Fitbit tokens**: `fitbit_sync/auth_data/` (created after authorization)
- **Configuration**: `config.py`

---

## Security Notes

⚠️ **WARNING**: Fitbit OAuth tokens are stored in **plain text** in the `fitbit_sync/auth_data/` directory.

**Do NOT expose port 8080 to the internet.** Only access the web interface from within your local network.

Consider:
- Keeping your Pi behind a firewall
- Using SSH tunneling if you need remote access
- Regularly updating your Pi's OS and packages

---

## Next Steps

Once everything is working:

1. Use the front button on the Wii Balance Board to take measurements
2. Weight data is automatically saved to `data/weight.csv`
3. If Fitbit sync is enabled, data syncs every 30 seconds
4. Check `log.txt` for system information and errors

---

## Support

If you encounter issues:

1. Check the troubleshooting section above
2. Review `log.txt` for error messages
3. Check the original project: https://github.com/yourusername/WiiFitBoardBit
4. Open an issue on GitHub with:
   - Raspberry Pi model
   - OS version (`cat /etc/os-release`)
   - Error messages from `log.txt`
   - Steps to reproduce the issue
