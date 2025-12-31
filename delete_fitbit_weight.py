#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Script to delete weight entries from Fitbit.
Run this to remove erroneous weight logs.
"""

import json
import sys
from datetime import datetime
from requests.auth import HTTPBasicAuth

from fitbit_sync.fitbit_oauth_user_client import FitBitOAuth2UserClient


def delete_weight_log(user_id, weight_log_id):
    """
    Delete a specific weight log entry from Fitbit
    @param user_id: The user ID (usually 1 for single user setup)
    @param weight_log_id: The Fitbit weight log ID to delete
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
            d = json.loads(response.content.decode('utf8'))
            if d['errors'][0]['errorType'] == 'expired_token':
                client.do_refresh_token()
                response = client.session.delete(url)

        if response.status_code == 204:
            print("Successfully deleted weight log ID: {}".format(weight_log_id))
            return True
        else:
            print("Failed to delete weight log. Status: {}, Response: {}".format(
                response.status_code, response.content))
            return False
    except Exception as e:
        print("Error deleting weight log: {}".format(e))
        return False


def list_weight_logs(user_id, date):
    """
    List all weight logs for a specific date
    @param user_id: The user ID (usually 1 for single user setup)
    @param date: Date string in format YYYY-MM-DD
    """
    client = FitBitOAuth2UserClient(user_id)

    if not client.is_authorised():
        print("Error: Fitbit sync is not configured or enabled")
        return None

    if not client.session:
        print("Error: Not authenticated with Fitbit")
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
            d = json.loads(response.content.decode('utf8'))
            if d['errors'][0]['errorType'] == 'expired_token':
                client.do_refresh_token()
                response = client.session.get(url)

        if response.status_code == 200:
            data = json.loads(response.content.decode('utf8'))
            return data.get('weight', [])
        else:
            print("Failed to get weight logs. Status: {}, Response: {}".format(
                response.status_code, response.content))
            return None
    except Exception as e:
        print("Error getting weight logs: {}".format(e))
        return None


if __name__ == '__main__':
    print("=" * 60)
    print("Fitbit Weight Log Manager")
    print("=" * 60)

    # Default to user 1 (most common for single-user setups)
    user_id = 1

    # List today's weight logs
    today = datetime.now().strftime('%Y-%m-%d')
    print("\nFetching weight logs for {}...".format(today))

    logs = list_weight_logs(user_id, today)

    if logs is None:
        print("Could not retrieve weight logs. Check your Fitbit authentication.")
        sys.exit(1)

    if not logs:
        print("No weight logs found for {}.".format(today))
        print("\nTry a different date by modifying the 'today' variable in this script.")
        sys.exit(0)

    print("\nFound {} weight log(s) for {}:".format(len(logs), today))
    print("-" * 60)

    for i, log in enumerate(logs, 1):
        print("{}. Log ID: {}".format(i, log['logId']))
        print("   Weight: {} {}".format(log['weight'], 'lbs' if 'lbs' in str(log) else 'kg'))
        print("   Time: {}".format(log['time']))
        print("   Date: {}".format(log['date']))
        print()

    print("-" * 60)
    print("\nTo delete a specific log, run:")
    print("  python2 delete_fitbit_weight.py <log_id>")
    print("\nExample:")
    print("  python2 delete_fitbit_weight.py {}".format(logs[0]['logId'] if logs else '1234567890'))
    print()

    # If a log ID was provided as argument, delete it
    if len(sys.argv) > 1:
        log_id = sys.argv[1]
        print("\nAttempting to delete log ID: {}".format(log_id))
        confirm = raw_input("Are you sure? (yes/no): ")
        if confirm.lower() == 'yes':
            delete_weight_log(user_id, log_id)
        else:
            print("Cancelled.")
