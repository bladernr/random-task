#!/usr/bin/env python3
import json
import argparse

def validate_json(json_str):
    try:
        json.loads(json_str)
        return True, None
    except ValueError as e:
        return False, str(e)

def explain_errors(error_message):
    if "Expecting property name enclosed in double quotes" in error_message:
        return "Error: Property names in JSON must be enclosed in double quotes."
    elif "Expecting value" in error_message:
        return "Error: Expecting a value in JSON."
    elif "No JSON object could be decoded" in error_message:
        return "Error: Invalid JSON format."
    else:
        return "Error: " + error_message

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Validate JSON from a file.")
    parser.add_argument("file", metavar="file_name", type=str, help="Name of the JSON file to validate.")
    args = parser.parse_args()

    try:
        # Read JSON data from file
        with open(args.file, 'r') as file:
            json_str = file.read()

        # Validate JSON
        is_valid, error_message = validate_json(json_str)

        # Explain errors if any
        if not is_valid:
            print(explain_errors(error_message))
        else:
            print("JSON is valid.")
    except FileNotFoundError:
        print("Error: File not found.")
    except Exception as e:
        print("An error occurred:", e)

