# Quick Start Guide - Raspberry Pi

Get your Wii Balance Board scale running in 4 steps!

## Step 1: Install Dependencies (15-30 minutes)

```bash
cd WiiFitBoardBit
chmod +x setup_raspberry_pi.sh
./setup_raspberry_pi.sh
```

This installs everything needed: Python 2, Bluez, XWiimote, and Python packages.

---

## Step 2: Pair Your Wii Balance Board (5 minutes)

Run Bluetooth controller:
```bash
sudo bluetoothctl
```

In bluetoothctl, run these commands:
```
power on
agent on
scan on
```

**Press the RED sync button** inside the battery compartment of your board.

When you see `Nintendo RVL-WBC-01`, note its MAC address (XX:XX:XX:XX:XX:XX).

Then run (replace XX:XX:XX:XX:XX:XX with your board's MAC):
```
pair XX:XX:XX:XX:XX:XX
connect XX:XX:XX:XX:XX:XX
trust XX:XX:XX:XX:XX:XX
disconnect XX:XX:XX:XX:XX:XX
scan off
exit
```

---

## Step 3: Run the Program

```bash
sudo python2 main.py
```

If you get library errors, try:
```bash
sudo LD_LIBRARY_PATH=/usr/lib PYTHONPATH=/usr/lib/python2.7/site-packages python2 main.py
```

---

## Step 4: Test It!

1. Press the **front button** on the Wii Balance Board (not the red one!)
2. The blue LED should turn on
3. Step on the board
4. Wait 5 seconds for reading to stabilize
5. Step off
6. LED turns off

Check your weight was logged:
```bash
cat data/weight.csv
```

---

## Optional: Auto-Start on Boot

```bash
chmod +x install_service.sh
sudo ./install_service.sh
```

---

## Optional: Fitbit Sync

1. Create app at https://dev.fitbit.com/apps
   - OAuth Type: **Personal**
   - Redirect URL: `http://127.0.0.1:8080/fitbit_auth_redirect`
   - Access: **Read & Write**

2. Edit `config.py`:
   ```python
   FITBIT_SYNC_ENABLED = True
   FITBIT_CLIENT_ID = "YOUR_CLIENT_ID"
   FITBIT_CLIENT_SECRET = "YOUR_CLIENT_SECRET"
   ```

3. After starting the program, open:
   ```
   http://YOUR_PI_IP_ADDRESS:8080/
   ```

   Find your Pi's IP: `hostname -I`

4. Authorize your Fitbit account

---

## Troubleshooting

**Board won't connect?**
- Check batteries
- Make sure you paired it (Step 2)
- Try re-pairing

**Import errors?**
- Use the LD_LIBRARY_PATH command above
- Check `TROUBLESHOOTING.md` for details

**No weight logged?**
- Step on firmly (need 5+ kg)
- Wait for reading to stabilize
- Check `log.txt` for errors

---

## Full Documentation

- **Detailed Setup:** See `SETUP_GUIDE.md`
- **Troubleshooting:** See `TROUBLESHOOTING.md`
- **Original README:** See `README.md`

---

## Daily Use

1. Press front button on board
2. Step on when LED turns on
3. Wait for measurement
4. Step off
5. Weight automatically logged to `data/weight.csv` and synced to Fitbit (if enabled)

That's it! 🎉
