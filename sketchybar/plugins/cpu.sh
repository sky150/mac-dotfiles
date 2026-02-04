#!/bin/bash

# Get CPU usage using top command
CPU_USAGE=$(top -l 2 -n 0 -F -s 0 | grep "CPU usage" | tail -1 | awk '{print $3}' | sed 's/%//')

# Convert to integer
CPU_INT=$(echo "$CPU_USAGE" | awk '{print int($1)}')

# Determine color based on usage
if [ "$CPU_INT" -gt 80 ]; then
  COLOR=0xfffc5d7c  # Red
elif [ "$CPU_INT" -gt 60 ]; then
  COLOR=0xfff39660  # Orange
elif [ "$CPU_INT" -gt 30 ]; then
  COLOR=0xffe7c664  # Yellow
else
  COLOR=0xff76cce0  # Blue
fi

# Update the graph (value between 0 and 1)
GRAPH_VALUE=$(echo "scale=2; $CPU_USAGE/100" | bc)
sketchybar --push cpu "$GRAPH_VALUE"

# Update label and color
sketchybar --set cpu \
  label="cpu ${CPU_INT}%" \
  graph.color="$COLOR"
