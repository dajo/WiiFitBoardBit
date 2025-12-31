#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Script to remove invalid weight entries (0.0 or very low values) from weight.csv
This helps clean up any erroneous measurements that were logged before validation was added.
"""

import csv
import os
import sys
from datetime import datetime

# Add the project root to the path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from config import WEIGHT_LOG_LOCATION, DATETIME_FORMAT

MIN_VALID_WEIGHT_KG = 20.0  # Same threshold used in weight_logger.py


def cleanup_weight_log():
    """Remove invalid weight entries from the CSV file"""

    weight_file = WEIGHT_LOG_LOCATION

    if not os.path.exists(weight_file):
        print("Weight log file not found: {}".format(weight_file))
        return

    # Read all entries
    valid_entries = []
    invalid_entries = []
    header = None

    with open(weight_file, 'r') as f:
        reader = csv.reader(f)
        header = next(reader)  # Save header

        for row in reader:
            if len(row) != 4:
                continue

            user_id, weight, date_str, synced = row
            weight_kg = float(weight)

            if weight_kg < MIN_VALID_WEIGHT_KG:
                invalid_entries.append(row)
            else:
                valid_entries.append(row)

    if not invalid_entries:
        print("No invalid weight entries found. Weight log is clean!")
        return

    print("Found {} invalid weight entries:".format(len(invalid_entries)))
    print("-" * 60)
    for row in invalid_entries:
        user_id, weight, date_str, synced = row
        print("  User {}: {:.2f} kg on {} (synced: {})".format(user_id, float(weight), date_str, synced))
    print("-" * 60)

    confirm = raw_input("\nRemove these {} invalid entries? (yes/no): ".format(len(invalid_entries)))

    if confirm.lower() != 'yes':
        print("Cancelled. No changes made.")
        return

    # Create backup
    backup_file = weight_file + '.backup.' + datetime.now().strftime('%Y%m%d_%H%M%S')
    print("\nCreating backup: {}".format(backup_file))

    with open(weight_file, 'r') as src:
        with open(backup_file, 'w') as dst:
            dst.write(src.read())

    # Write cleaned data
    print("Writing cleaned data to {}...".format(weight_file))
    with open(weight_file, 'w') as f:
        writer = csv.writer(f)
        writer.writerow(header)
        writer.writerows(valid_entries)

    print("\nSuccess! Removed {} invalid entries.".format(len(invalid_entries)))
    print("Kept {} valid entries.".format(len(valid_entries)))
    print("Backup saved to: {}".format(backup_file))


if __name__ == '__main__':
    print("=" * 60)
    print("Weight Log Cleanup Utility")
    print("=" * 60)
    print("\nThis script will remove weight entries below {:.1f} kg (~{:.1f} lbs)".format(
        MIN_VALID_WEIGHT_KG, MIN_VALID_WEIGHT_KG * 2.2))
    print()

    cleanup_weight_log()
