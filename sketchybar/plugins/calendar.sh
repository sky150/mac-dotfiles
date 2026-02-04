#!/bin/bash

# Format: HH:MM then date (e.g. "21:45" and "25. Jan")
TIME=$(date "+%H:%M")
DATE=$(date "+%d.%b")

# Update calendar item
sketchybar --set calendar \
  icon="$TIME" \
  label="$DATE"
