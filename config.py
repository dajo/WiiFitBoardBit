# -*- coding: utf-8 -*-
# =============================================== FitBit Synchronization ===============================================
# Change to True to enable weight synchronization with FitBit. Go to http://localhost:8080/ for more info.

# WARNING! You should not expose the default http port (80) of the device you're running this on to the outside of your
# network. FitBit OAuth2 tokens are stored in plain text therefore the security of the tokens directly correlate to the
# security of this project folder.
FITBIT_SYNC_ENABLED = False

# Set up a new app for yourself at https://dev.fitbit.com/apps
#
# To set up your application go to https://dev.fitbit.com/apps
# Application Website URL: Use your GitHub account or something else
# Organization: Can enter 'N/A'
# Organization Website URL: Use your GitHub account or something else
# Terms of Service URL: Link to FitBit ToS
# Privacy Policy URL: Link to FitBit Privacy Policy URL
# OAuth 2.0 Application Type: Personal
# Redirect URL: https://YOUR_PI_IP:8080/fitbit_auth_redirect (e.g. https://192.168.1.237:8080/fitbit_auth_redirect)
# Default Access Type: Read and Write
#
# RECOMMENDED: Create a file called 'fitbit_credentials.py' with your credentials (see fitbit_credentials.py.example)
# This keeps your credentials out of git. Otherwise, set them here:
FITBIT_CLIENT_ID = None
FITBIT_CLIENT_SECRET = None

# Fitbit OAuth redirect URL - should match what you set in your Fitbit app settings
# Format: https://YOUR_PI_IP:8080/fitbit_auth_redirect
# Example: https://192.168.1.237:8080/fitbit_auth_redirect
FITBIT_REDIRECT_URL = None  # Set this to your Pi's IP address with https and port 8080

# Try to import credentials from fitbit_credentials.py (not tracked by git)
try:
    from fitbit_credentials import FITBIT_CLIENT_ID as _CLIENT_ID, FITBIT_CLIENT_SECRET as _CLIENT_SECRET
    FITBIT_CLIENT_ID = _CLIENT_ID
    FITBIT_CLIENT_SECRET = _CLIENT_SECRET
except ImportError:
    pass  # Use values set above (None by default)

# Try to import redirect URL from fitbit_credentials.py as well
try:
    from fitbit_credentials import FITBIT_REDIRECT_URL as _REDIRECT_URL
    FITBIT_REDIRECT_URL = _REDIRECT_URL
except ImportError:
    pass  # Use value set above (None by default)

# How often to attempt weight logging on FitBit
WEIGHT_SYNC_LOOP_TIME_SECS = 30
# ======================================================================================================================


# ================================================= Weight Fluctuation =================================================
# The following value is used to determine which weight belongs to which user. New weights are compared against each
# user's MOST RECENT weight (not their first weight). If the difference exceeds this amount, a new user is created.
#
# IMPORTANT: This is always in KG regardless of UNITS setting. (10 kg ≈ 22 lbs)
#
# NOTE: You can lose/gain more than this amount over time! Each measurement is only compared to your PREVIOUS weight.
# For example, if you start at 100 kg and lose 1 kg per week, all measurements will be assigned to the same user
# because each new weight is within 10 kg of the previous one.
#
# Example with multiple users:
# - User 1's latest weight: 100 kg
# - User 2's latest weight: 60 kg
# - New measurement: 98.9 kg → difference from User 1 is 1.1 kg (within 10 kg) → assigned to User 1
# - New measurement: 81 kg → difference from User 1 is 17.1 kg, from User 2 is 21 kg → both exceed 10 kg → new User 3
#
# Lower values might cause issues when measuring weight between long periods of time. This system might not work well
# for multiple users with very similar weights.
#
ALLOWED_WEIGHT_FLUCTUATION_KG = 10.0  # Always in KG (≈ 22 lbs)
# ======================================================================================================================


# ======================================================= Other ========================================================
# Various other settings, there should be no reason to change these
UNITS = 'METRIC'  # Set 'METRIC' for kg, 'IMPERIAL' for pounds.
DATETIME_FORMAT = "%Y-%m-%d %H:%M:%S"  # Sets the date format in which to store the weight
WEIGHT_LOG_LOCATION = "data/weight.csv"  # Sets the weight file location
LOG_LOCATION = 'log.txt'  # Sets the log file location for general system info and error output
BALANCE_BOARD_MAC = None  # (optional) Can set your wii balance board MAC address if you already know it
# ======================================================================================================================
