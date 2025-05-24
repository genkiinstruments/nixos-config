#!/usr/bin/env bash

# A simple script to copy text to clipboard using OSC52 escape sequence
# This works even over SSH connections

# Read from stdin
buf=$(cat)

# Get base64 encoded version, removing newlines
b64=$(echo -n "$buf" | base64 | tr -d '\n')

# Send the OSC52 sequence to the terminal
printf "\033]52;c;%s\007" "$b64"

