# Manual Installation Guide for Raspberry Pi OS Bookworm

This guide covers manual installation for Raspberry Pi OS Bookworm (and Bullseye), where Python 2 has been removed from default repositories.

## Prerequisites Check

First, run the verification script to see what you already have:

```bash
./verify_installation.sh
```

---

## Step 1: Install System Dependencies

```bash
sudo apt-get update
sudo apt-get install -y \
    bluez \
    build-essential \
    git \
    autoconf \
    libtool \
    libudev-dev \
    libncurses5-dev \
    swig \
    libcairo2-dev \
    libgirepository1.0-dev \
    libssl-dev \
    libdbus-glib-1-dev \
    curl
```

---

## Step 2: Install Python 2.7

### Option A: From System Packages (Recommended)

```bash
# Install Python 2.7 if available
sudo apt-get install -y python2.7 python2.7-dev

# Create symlink for 'python2' command
sudo ln -sf /usr/bin/python2.7 /usr/bin/python2

# Verify installation
python2 --version
```

### Option B: If Python 2.7 is Already Installed

Check if you already have it:

```bash
which python2.7
python2.7 --version
```

If it exists, just create the symlink:

```bash
sudo ln -sf /usr/bin/python2.7 /usr/bin/python2
```

---

## Step 3: Install pip2

### Method 1: Using get-pip.py (Recommended)

```bash
# Download and install pip for Python 2.7
curl https://bootstrap.pypa.io/pip/2.7/get-pip.py -o /tmp/get-pip.py
sudo python2.7 /tmp/get-pip.py
rm /tmp/get-pip.py

# Verify installation
pip2 --version
```

### Method 2: From Package Manager (if available)

```bash
sudo apt-get install python-pip
```

---

## Step 4: Install Python 2 System Packages

Try to install available system packages (some may not be available on Bookworm):

```bash
# These may or may not be available depending on your OS version
sudo apt-get install -y \
    python-dbus \
    python-numpy \
    python-cairo \
    python-gi
```

**Note:** If these fail, don't worry - we'll install them via pip2 later.

---

## Step 5: Install XWiimote Driver

```bash
# Create build directory
mkdir -p /tmp/wiimote_build
cd /tmp/wiimote_build

# Clone XWiimote
git clone https://github.com/dvdhrm/xwiimote.git
cd xwiimote

# Build and install
./autogen.sh --prefix=/usr
make
sudo make install

cd ..
```

---

## Step 6: Install XWiimote Python Bindings

```bash
# Still in /tmp/wiimote_build directory
git clone https://github.com/dvdhrm/xwiimote-bindings.git
cd xwiimote-bindings

# Build and install
./autogen.sh --prefix=/usr
make
sudo make install

# Update library cache
sudo ldconfig
```

---

## Step 7: Install Python Dependencies via pip2

Navigate to your WiiFitBoardBit directory:

```bash
cd ~/git/WiiFitBoardBit  # or wherever your repo is
```

### Install packages that may not be in system repos:

```bash
# Install dbus-python if not available as system package
sudo pip2 install dbus-python

# Install packages from requirements.txt
sudo pip2 install -r requirements.txt
```

### If you get specific errors, install packages individually:

```bash
sudo pip2 install wheel setuptools
sudo pip2 install six==1.16.0
sudo pip2 install numpy==1.16.6
sudo pip2 install requests==2.27.1
sudo pip2 install requests-oauthlib==1.3.1
sudo pip2 install flask==1.1.4
sudo pip2 install flask-bootstrap==3.3.7.1
sudo pip2 install pyopenssl==21.0.0
```

### For packages that need system libraries:

If `dbus-python` fails:
```bash
sudo apt-get install libdbus-1-dev libdbus-glib-1-dev
sudo pip2 install dbus-python
```

If `pycairo` fails:
```bash
sudo apt-get install libcairo2-dev
sudo pip2 install pycairo==1.18.2
```

If `pygobject` fails:
```bash
sudo apt-get install libgirepository1.0-dev
sudo pip2 install pygobject==3.36.1
```

---

## Step 8: Verify Installation

Run the verification script:

```bash
./verify_installation.sh
```

You should see all green checkmarks (✓) for:
- Python 2
- pip2
- xwiimote module
- dbus module
- Other required modules

---

## Step 9: Test the Installation

Try importing all required modules:

```bash
python2 << 'EOF'
import sys
print("Python version:", sys.version)

modules = ['xwiimote', 'dbus', 'numpy', 'six', 'requests', 'flask', 'requests_oauthlib']
for module in modules:
    try:
        __import__(module)
        print("✓", module)
    except ImportError as e:
        print("✗", module, "-", str(e))
EOF
```

---

## Common Issues and Solutions

### Issue: "No module named xwiimote"

**Check where XWiimote bindings were installed:**
```bash
find /usr -name "_xwiimote.so" 2>/dev/null
```

**Set PYTHONPATH to include the location:**
```bash
export PYTHONPATH=/usr/lib/python2.7/site-packages:/usr/local/lib/python2.7/site-packages
python2 -c "import xwiimote; print('XWiimote OK')"
```

**Make it permanent:**
Add to `~/.bashrc`:
```bash
echo 'export PYTHONPATH=/usr/lib/python2.7/site-packages:/usr/local/lib/python2.7/site-packages' >> ~/.bashrc
source ~/.bashrc
```

---

### Issue: "ImportError: libxwiimote.so.2: cannot open shared object file"

**Update library cache:**
```bash
sudo ldconfig
```

**Check library path:**
```bash
find /usr -name "libxwiimote.so*" 2>/dev/null
```

**Set LD_LIBRARY_PATH:**
```bash
export LD_LIBRARY_PATH=/usr/lib:/usr/local/lib
sudo ldconfig
```

---

### Issue: pip2 installs but "command not found"

**Find where pip2 was installed:**
```bash
find /usr -name "pip2*" 2>/dev/null
```

**Create symlink if needed:**
```bash
sudo ln -s /usr/local/bin/pip2 /usr/bin/pip2
```

Or use the full path:
```bash
/usr/local/bin/pip2 install -r requirements.txt
```

---

### Issue: "python2: command not found" but python2.7 exists

**Create symlink:**
```bash
sudo ln -sf /usr/bin/python2.7 /usr/bin/python2
```

---

## Alternative: Use Docker (Advanced)

If manual installation is too problematic, you could run this in a Docker container with an older Debian version:

```bash
# Create a Dockerfile with Debian Buster (has Python 2)
# This is more complex and requires Docker knowledge
# Not recommended for typical Raspberry Pi use
```

---

## Running the Program

Once everything is installed, run:

```bash
sudo python2 main.py
```

If you still get library errors:

```bash
sudo LD_LIBRARY_PATH=/usr/lib:/usr/local/lib \
     PYTHONPATH=/usr/lib/python2.7/site-packages:/usr/local/lib/python2.7/site-packages \
     python2 main.py
```

---

## Making Environment Variables Permanent

If you need to set `LD_LIBRARY_PATH` and `PYTHONPATH` every time, add them to the systemd service file.

Edit `wiifitboardbit.service` and ensure these lines are present:

```ini
[Service]
Environment="LD_LIBRARY_PATH=/usr/lib:/usr/local/lib"
Environment="PYTHONPATH=/usr/lib/python2.7/site-packages:/usr/local/lib/python2.7/site-packages"
```

---

## Next Steps

After successful installation:
1. Pair your Wii Balance Board (see SETUP_GUIDE.md Step 2)
2. Configure Fitbit sync if desired (see SETUP_GUIDE.md Step 3)
3. Set up auto-start with systemd (see SETUP_GUIDE.md Step 5)

---

## Getting Help

If you're still stuck after following this guide:

1. Run `./verify_installation.sh` and share the output
2. Check `TROUBLESHOOTING.md` for specific error messages
3. Share your OS version: `cat /etc/os-release`
4. Share exact error messages from the installation

Good luck! 🚀
