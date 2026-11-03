#!/usr/bin/env python3
"""
Minimal tracker validator.
Checks that required columns exist and that status values are known.
Uses only the standard library. Safe to run against a local CSV.
"""

import csv
import sys

REQUIRED = ["id", "company", "title", "status", "date_reviewed"]
KNOWN_STATUS = {"Apply", "Stretch", "Pass", "Applied", "Rejected", "Withdrawn"}

def validate(path):
    errors = []
    with open(path, newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        if not reader.fieldnames:
            return ["Empty file or missing header"]
        missing = [col for col in REQUIRED if col not in reader.fieldnames]
        if missing:
            errors.append(f"Missing columns: {', '.join(missing)}")
        for i, row in enumerate(reader, start=2):
            status = row.get("status", "").strip()
            if status and status not in KNOWN_STATUS:
                errors.append(f"Line {i}: unknown status '{status}'")
            if not row.get("id", "").strip():
                errors.append(f"Line {i}: missing id")
    return errors

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: validate_tracker.py <file.csv>")
        sys.exit(1)
    problems = validate(sys.argv[1])
    if problems:
        print("Validation failed:")
        for p in problems:
            print(f"  {p}")
        sys.exit(1)
    print("Validation passed.")
