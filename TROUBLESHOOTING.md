# WiiFitBoardBit Troubleshooting Guide

This guide covers common issues and their solutions when setting up and running WiiFitBoardBit on Raspberry Pi.

---

## Table of Contents

1. [Installation Issues](#installation-issues)
2. [Bluetooth & Pairing Issues](#bluetooth--pairing-issues)
3. [Python & Library Issues](#python--library-issues)
4. [Runtime Issues](#runtime-issues)
5. [Fitbit Sync Issues](#fitbit-sync-issues)
6. [Systemd Service Issues](#systemd-service-issues)
7. [Data & Logging Issues](#data--logging-issues)

---

## Installation Issues

### setup_raspberry_pi.sh fails with "apt-get not found"

**Cause:** Not running on a Debian-based system.

**Solution:** This project requires Raspberry Pi OS (Raspbian) or another Debian-based distribution. Install manually on other systems.

---

### "E: Unable to locate package python2"

**Cause:** Python 2 is deprecated and may not be in default repositories on newer OS versions.

**Solution:**
```bash
# On newer Raspberry Pi OS, try:
sudo apt-get update
sudo apt-get install python2.7 python2.7-dev

# Create a symlink
sudo ln -s /usr/bin/python2.7 /usr/bin/python2
```

---

### XWiimote compilation fails

**Cause:** Missing build dependencies.

**Solution:**
```bash
sudo apt-get install -y \
    build-essential \
    autoconf \
    automake \
    libtool \
    pkg-config \
    libudev-dev \
    libncurses5-dev
```

Then retry the installation:
```bash
cd /tmp/wiimote_build/xwiimote
./autogen.sh --prefix=/usr
make clean
make
sudo make install
```

---

### XWiimote-bindings compilation fails

**Cause:** Missing Python development files or SWIG.

**Solution:**
```bash
sudo apt-get install -y \
    swig \
    python2.7-dev \
    python-numpy \
    libcairo2-dev \
    libgirepository1.0-dev
```

Then retry:
```bash
cd /tmp/wiimote_build/xwiimote-bindings
./autogen.sh --prefix=/usr
make clean
make
sudo make install
sudo ldconfig
```

---

## Bluetooth & Pairing Issues

### Wii Balance Board not showing up in scan

**Symptoms:**
- `scan on` doesn't show "Nintendo RVL-WBC-01"
- No new devices appear when pressing sync button

**Solutions:**

1. **Check Bluetooth is running:**
   ```bash
   sudo systemctl status bluetooth
   ```
   If not running:
   ```bash
   sudo systemctl start bluetooth
   sudo systemctl enable bluetooth
   ```

2. **Check Bluetooth adapter:**
   ```bash
   hciconfig
   ```
   Should show `hci0` or similar. If not, Bluetooth hardware issue.

3. **Restart Bluetooth:**
   ```bash
   sudo systemctl restart bluetooth
   sudo bluetoothctl
   power off
   power on
   scan on
   ```

4. **Replace batteries** - Weak batteries cause pairing issues

5. **Press sync button firmly** - Hold for 1-2 seconds until LED blinks rapidly

---

### Pairing succeeds but connection fails

**Symptoms:**
- `pair XX:XX:XX:XX:XX:XX` succeeds
- `connect XX:XX:XX:XX:XX:XX` fails with timeout

**Solution:**

The connection timeout is very short. You must run `connect` **immediately** after `pair` succeeds:

```bash
pair XX:XX:XX:XX:XX:XX && connect XX:XX:XX:XX:XX:XX
```

Or press the red sync button again and retry.

---

### Board connects but disconnects immediately

**Cause:** Board not trusted.

**Solution:**
```bash
sudo bluetoothctl
trust XX:XX:XX:XX:XX:XX
```

---

### "Can't find balance board" error when running

**Symptoms:**
- Program starts but says "Waiting for board..."
- Board doesn't connect when front button pressed

**Solutions:**

1. **Check board is paired and trusted:**
   ```bash
   sudo bluetoothctl
   devices
   info XX:XX:XX:XX:XX:XX
   ```
   Should show `Trusted: yes`

2. **Set MAC address in config.py:**
   ```python
   BALANCE_BOARD_MAC = "XX:XX:XX:XX:XX:XX"
   ```

3. **Try connecting manually first:**
   ```bash
   sudo bluetoothctl
   connect XX:XX:XX:XX:XX:XX
   ```
   Then run the program.

4. **Check board is in range** - Bluetooth range is ~10 meters

---

## Python & Library Issues

### ImportError: No module named xwiimote

**Cause:** XWiimote Python bindings not in Python path.

**Solution 1 - Set environment variables:**
```bash
export LD_LIBRARY_PATH=/usr/lib:/usr/local/lib
export PYTHONPATH=/usr/lib/python2.7/site-packages:/usr/local/lib/python2.7/site-packages
sudo -E python2 main.py
```

**Solution 2 - Find correct path:**
```bash
find /usr -name "*xwiimote*.so" 2>/dev/null
```

Use the directory containing `xwiimote.so`:
```bash
export PYTHONPATH=/path/to/directory
```

**Solution 3 - Reinstall with different prefix:**
```bash
cd /tmp/wiimote_build/xwiimote-bindings
./autogen.sh --prefix=/usr/local
make clean
make
sudo make install
sudo ldconfig
```

---

### ImportError: No module named dbus

**Cause:** python-dbus not installed.

**Solution:**
```bash
sudo apt-get install python-dbus
```

---

### ImportError: No module named flask

**Cause:** Flask not installed (needed for Fitbit sync).

**Solution:**
```bash
pip2 install --user flask flask-bootstrap
# OR
sudo pip2 install flask flask-bootstrap
```

---

### ImportError: No module named requests_oauthlib

**Cause:** OAuth library not installed.

**Solution:**
```bash
sudo apt-get install python-oauthlib
pip2 install --user requests requests-oauthlib
```

---

### "No module named gi" or "No module named cairo"

**Cause:** Missing Python GObject introspection or Cairo.

**Solution:**
```bash
sudo apt-get install python-gi python-cairo libgirepository1.0-dev
```

---

## Runtime Issues

### Permission denied errors

**Symptoms:**
- "Permission denied" when accessing Bluetooth
- "Could not open device" errors

**Solution:**

Always run with `sudo`:
```bash
sudo python2 main.py
```

Or add your user to bluetooth group (requires logout):
```bash
sudo usermod -a -G bluetooth $USER
```

---

### Program starts but nothing happens

**Symptoms:**
- Program runs without errors
- Pressing front button does nothing
- No weight logged

**Diagnostic steps:**

1. **Check logs:**
   ```bash
   tail -f log.txt
   ```

2. **Check Bluetooth connection:**
   ```bash
   sudo bluetoothctl
   devices
   info XX:XX:XX:XX:XX:XX
   ```

3. **Test board connection:**
   - Press front button on board
   - LED should turn on
   - Check `log.txt` for connection attempts

4. **Run in foreground with debug:**
   Add to `main.py` before `logging.basicConfig()`:
   ```python
   level=logging.DEBUG
   ```

---

### Board connects but no weight reading

**Symptoms:**
- Board LED turns on
- Connection established
- No weight value logged

**Solutions:**

1. **Step on the board firmly** - Need at least 5-10 kg for reading

2. **Wait for stabilization** - Takes 3-5 seconds

3. **Check calibration** - Board may need recalibration (see Wii Fit game)

4. **Check logs** for errors:
   ```bash
   cat log.txt | grep -i error
   ```

---

### Weight readings are incorrect

**Symptoms:**
- Weight logged but value is wrong
- Values fluctuate wildly

**Solutions:**

1. **Check units in config.py:**
   ```python
   UNITS = 'METRIC'  # or 'IMPERIAL'
   ```

2. **Calibrate the board:**
   - Use Wii Fit game to recalibrate
   - Or verify with known weight

3. **Place board on hard, flat surface** - Carpet causes issues

4. **Check battery level** - Low batteries cause inaccurate readings

---

## Fitbit Sync Issues

### "Fitbit synchronisation is disabled" message

**Cause:** Fitbit sync not enabled.

**Solution:**

Edit `config.py`:
```python
FITBIT_SYNC_ENABLED = True
FITBIT_CLIENT_ID = "YOUR_CLIENT_ID"
FITBIT_CLIENT_SECRET = "YOUR_CLIENT_SECRET"
```

---

### Can't access http://localhost:8080

**Symptoms:**
- Browser shows "Connection refused"
- Can't authorize Fitbit

**Solutions:**

1. **Check if web server is running:**
   ```bash
   sudo netstat -tlnp | grep 8080
   ```

2. **Check logs:**
   ```bash
   cat log.txt | grep -i flask
   ```

3. **Use Pi's IP address instead:**
   ```
   http://192.168.1.XXX:8080/
   ```
   Find IP with: `hostname -I`

4. **Check firewall:**
   ```bash
   sudo ufw status
   ```
   Allow if needed:
   ```bash
   sudo ufw allow 8080/tcp
   ```

---

### Fitbit authorization fails

**Symptoms:**
- "Invalid client_id" error
- "Redirect URI mismatch" error

**Solutions:**

1. **Verify credentials in config.py** match Fitbit developer app

2. **Check redirect URL** in Fitbit app settings:
   - Should be: `http://127.0.0.1:8080/fitbit_auth_redirect`
   - OR: `http://YOUR_PI_IP:8080/fitbit_auth_redirect`

3. **Check Application Type** is set to "Personal"

4. **Try registering a new Fitbit app** if issues persist

---

### Weight syncs to wrong Fitbit account

**Cause:** Multiple users sharing the board.

**Solution:**

The program assigns weights to users based on `ALLOWED_WEIGHT_FLUCTUATION_KG` in `config.py`:

```python
ALLOWED_WEIGHT_FLUCTUATION_KG = 10.0  # Adjust this value
```

- Lower value = more sensitive to weight changes
- Higher value = allows more fluctuation per user

For multiple users with similar weights, consider:
- Disabling Fitbit sync and manually logging
- Using separate instances with different user setups

---

### OAuth token expired errors

**Symptoms:**
- "Token expired" in logs
- Sync worked before but stopped

**Solution:**

1. **Delete old tokens:**
   ```bash
   rm -rf fitbit_sync/auth_data/*
   ```

2. **Re-authorize:**
   - Go to `http://YOUR_PI_IP:8080/`
   - Follow authorization steps again

---

### Need to re-authorize after every restart

**Symptoms:**
- Must visit http://YOUR_PI_IP:8080/ and authorize after every reboot
- "Please check user authentication" errors after restart
- Weight logs but doesn't sync to Fitbit

**Cause:** OAuth tokens aren't being saved/loaded properly. This is usually a file permissions issue.

**Diagnostic:**

1. **Check if token files exist:**
   ```bash
   cd /path/to/WiiFitBoardBit
   ./check_fitbit_tokens.sh
   ```

2. **Check permissions:**
   ```bash
   ls -la fitbit_sync/auth_data/
   ```

**Solutions:**

1. **Fix permissions** (if files exist but aren't readable):
   ```bash
   cd /path/to/WiiFitBoardBit
   sudo chown -R $USER:$USER fitbit_sync/auth_data/
   chmod -R 755 fitbit_sync/auth_data/
   ```

2. **Ensure directory persists** (create if missing):
   ```bash
   mkdir -p fitbit_sync/auth_data
   chmod 755 fitbit_sync/auth_data
   ```

3. **After fixing permissions, restart the service:**
   ```bash
   sudo systemctl restart wiifitboardbit
   ```

4. **Re-authorize ONE MORE TIME:**
   - Visit `http://YOUR_PI_IP:8080/`
   - Complete authorization
   - Check that `fitbit_sync/auth_data/user_1.json` was created
   - Restart and verify it persists

**Prevention:** The auth_data directory is now gitignored and created automatically. If you're still having issues, the systemd service might be running with conflicting permissions.

---

## Systemd Service Issues

### Service fails to start

**Symptoms:**
- `systemctl start wiifitboardbit` fails
- Service shows "failed" status

**Diagnostic:**
```bash
sudo systemctl status wiifitboardbit.service
sudo journalctl -u wiifitboardbit.service -n 50
```

**Common causes:**

1. **Wrong path in service file:**
   Edit `/etc/systemd/system/wiifitboardbit.service`:
   ```ini
   WorkingDirectory=/home/pi/WiiFitBoardBit
   ExecStart=/usr/bin/python2 /home/pi/WiiFitBoardBit/main.py
   ```
   Adjust paths for your installation.

2. **Missing environment variables:**
   Add to service file under `[Service]`:
   ```ini
   Environment="LD_LIBRARY_PATH=/usr/lib:/usr/local/lib"
   Environment="PYTHONPATH=/usr/lib/python2.7/site-packages"
   ```

3. **Wrong permissions:**
   ```bash
   sudo chmod 644 /etc/systemd/system/wiifitboardbit.service
   sudo systemctl daemon-reload
   ```

---

### Service starts but doesn't work

**Symptoms:**
- Service shows "active (running)"
- Board doesn't respond

**Diagnostic:**
```bash
sudo journalctl -u wiifitboardbit.service -f
```

Check for errors and compare to running manually:
```bash
sudo systemctl stop wiifitboardbit
sudo python2 /home/pi/WiiFitBoardBit/main.py
```

---

## Data & Logging Issues

### No data/weight.csv file

**Cause:** Data directory doesn't exist or permissions issue.

**Solution:**
```bash
mkdir -p data
chmod 755 data
sudo chown pi:pi data  # Replace 'pi' with your username
```

---

### Can't read log.txt

**Cause:** File doesn't exist or permissions.

**Solution:**
```bash
touch log.txt
chmod 644 log.txt
sudo chown pi:pi log.txt
```

---

### CSV file not updating

**Symptoms:**
- Program runs
- Weight measured
- No new entries in CSV

**Diagnostic:**

1. **Check file permissions:**
   ```bash
   ls -la data/weight.csv
   ```

2. **Check file is being written:**
   ```bash
   tail -f data/weight.csv
   ```
   While stepping on board.

3. **Check logs for errors:**
   ```bash
   cat log.txt | grep -i error
   ```

---

## Getting More Help

If your issue isn't covered here:

1. **Check application logs:**
   ```bash
   cat log.txt
   ```

2. **Check system logs:**
   ```bash
   sudo journalctl -xe
   ```

3. **Test Bluetooth separately:**
   ```bash
   sudo bluetoothctl
   scan on
   # Test pairing with board
   ```

4. **Test Python imports:**
   ```bash
   python2 -c "import xwiimote; print('XWiimote OK')"
   python2 -c "import dbus; print('DBus OK')"
   python2 -c "import flask; print('Flask OK')"
   ```

5. **Gather information for issue report:**
   - Raspberry Pi model: `cat /proc/device-tree/model`
   - OS version: `cat /etc/os-release`
   - Python version: `python2 --version`
   - Bluetooth version: `bluetoothctl --version`
   - Error messages from `log.txt`
   - Output of `sudo systemctl status wiifitboardbit`

6. **Open a GitHub issue** with the above information

---

## Useful Commands Reference

```bash
# Service management
sudo systemctl start wiifitboardbit
sudo systemctl stop wiifitboardbit
sudo systemctl restart wiifitboardbit
sudo systemctl status wiifitboardbit
sudo journalctl -u wiifitboardbit -f

# Bluetooth
sudo systemctl restart bluetooth
sudo bluetoothctl

# Logs
tail -f log.txt
cat log.txt | grep -i error
tail -f data/weight.csv

# Test run
sudo python2 main.py

# Test with debug paths
sudo LD_LIBRARY_PATH=/usr/lib PYTHONPATH=/usr/lib/python2.7/site-packages python2 main.py

# Check processes
ps aux | grep python2
ps aux | grep bluetooth

# Network
hostname -I
sudo netstat -tlnp | grep 8080
```
