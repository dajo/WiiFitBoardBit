#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Script to delete weight entries from Fitbit.
Run this to remove erroneous weight logs.

Usage:
    python2 delete_fitbit_weight.py              # List today's weight logs
    python2 delete_fitbit_weight.py <log_id>     # Delete a specific log
    python2 delete_fitbit_weight.py <date>       # List logs for a specific date (YYYY-MM-DD)
"""

import json
import sys
import os
from datetime import datetime

# Add the project root to the path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

# Now we can import from the project
from fitbit_sync.fitbit_oauth_user_client import FitBitOAuth2UserClient


def delete_weight_log(user_id, weight_log_id):
    """
    Delete a specific weight log entry from Fitbit
    """
    client = FitBitOAuth2UserClient(user_id)

    if not client.is_authorised():
        print("Error: Fitbit sync is not configured or enabled")
        return False

    if not client.session:
        print("Error: Not authenticated with Fitbit")
        return False

    url = '{}/{}/user/-/body/log/weight/{}.json'.format(
        client.API_ENDPOINT,
        client.API_VERSION,
        weight_log_id
    )

    try:
        response = client.session.delete(url)

        # Handle expired token
        if response.status_code == 401:
            try:
                d = json.loads(response.content.decode('utf8'))
                if d.get('errors', [{}])[0].get('errorType') == 'expired_token':
                    print("Token expired, refreshing...")
                    client.do_refresh_token()
                    response = client.session.delete(url)
            except:
                pass

        if response.status_code == 204:
            print("Successfully deleted weight log ID: {}".format(weight_log_id))
            return True
        else:
            print("Failed to delete weight log.")
            print("Status: {}".format(response.status_code))
            print("Response: {}".format(response.content))
            return False
    except Exception as e:
        print("Error deleting weight log: {}".format(e))
        return False


def list_weight_logs(user_id, date):
    """
    List all weight logs for a specific date
    """
    client = FitBitOAuth2UserClient(user_id)

    if not client.is_authorised():
        print("Error: Fitbit sync is not configured or enabled")
        print("Make sure FITBIT_SYNC_ENABLED = True in config.py")
        return None

    if not client.session:
        print("Error: Not authenticated with Fitbit")
        print("Visit http://YOUR_PI_IP:8080/ to authenticate")
        return None

    url = '{}/{}/user/-/body/log/weight/date/{}.json'.format(
        client.API_ENDPOINT,
        client.API_VERSION,
        date
    )

    try:
        response = client.session.get(url)

        # Handle expired token
        if response.status_code == 401:
            try:
                d = json.loads(response.content.decode('utf8'))
                if d.get('errors', [{}])[0].get('errorType') == 'expired_token':
                    print("Token expired, refreshing...")
                    client.do_refresh_token()
                    response = client.session.get(url)
            except:
                pass

        if response.status_code == 200:
            data = json.loads(response.content.decode('utf8'))
            return data.get('weight', [])
        else:
            print("Failed to get weight logs.")
            print("Status: {}".format(response.status_code))
            print("Response: {}".format(response.content))
            return None
    except Exception as e:
        print("Error getting weight logs: {}".format(e))
        import traceback
        traceback.print_exc()
        return None


def main():
    print("=" * 70)
    print("Fitbit Weight Log Manager")
    print("=" * 70)

    # Default to user 1 (most common for single-user setups)
    user_id = 1

    # Check if we're deleting a specific log ID
    if len(sys.argv) > 1:
        arg = sys.argv[1]

        # Check if it's a log ID (numeric) or a date (contains dashes)
        if '-' in arg and len(arg) == 10:
            # It's a date in YYYY-MM-DD format
            date = arg
        elif arg.isdigit():
            # It's a log ID - delete it
            log_id = arg
            print("\nAttempting to delete log ID: {}".format(log_id))
            confirm = raw_input("Are you sure you want to delete this log? (yes/no): ")
            if confirm.lower() == 'yes':
                delete_weight_log(user_id, log_id)
            else:
                print("Cancelled.")
            return
        else:
            print("Invalid argument. Use a log ID (numeric) or date (YYYY-MM-DD)")
            return
    else:
        # Default to today
        date = datetime.now().strftime('%Y-%m-%d')

    # List weight logs for the date
    print("\nFetching weight logs for {}...".format(date))
    logs = list_weight_logs(user_id, date)

    if logs is None:
        print("\nCould not retrieve weight logs.")
        print("Make sure:")
        print("  1. FITBIT_SYNC_ENABLED = True in config.py")
        print("  2. You've authenticated at http://YOUR_PI_IP:8080/")
        return

    if not logs:
        print("No weight logs found for {}.".format(date))
        print("\nTo check a different date:")
        print("  python2 delete_fitbit_weight.py 2025-12-30")
        return

    print("\nFound {} weight log(s) for {}:".format(len(logs), date))
    print("-" * 70)

    for i, log in enumerate(logs, 1):
        print("{}. Log ID: {}".format(i, log['logId']))
        print("   Weight: {} lbs".format(log.get('weight', 'N/A')))
        print("   Time: {}".format(log.get('time', 'N/A')))
        print("   Date: {}".format(log.get('date', 'N/A')))
        if 'bmi' in log:
            print("   BMI: {}".format(log['bmi']))
        print()

    print("-" * 70)
    print("\nTo delete a specific log, run:")
    print("  python2 delete_fitbit_weight.py <log_id>")
    print("\nExamples:")
    if logs:
        print("  python2 delete_fitbit_weight.py {}".format(logs[0]['logId']))
    print("  python2 delete_fitbit_weight.py 2025-12-30  # List logs for a different date")
    print()


if __name__ == '__main__':
    main()
