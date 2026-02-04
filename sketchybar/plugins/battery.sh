#!/bin/bash

# --- Variablen & Farben ---
PERCENTAGE=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
CHARGING=$(pmset -g batt | grep 'AC Power')

if [ "$PERCENTAGE" = "" ]; then exit 0; fi

COLOR_GREEN=0xffa6da95
COLOR_YELLOW=0xffeed49f
COLOR_ORANGE=0xfff5a97f
COLOR_RED=0xffed8796
COLOR_DEFAULT=0xffcdd6f4 # Textfarbe

# --- Icons (SF Symbols) ---
# Entspricht der Felix Kratz Logik
ICON_100="􀛨"
ICON_75="􀛩"
ICON_50="􀛪"
ICON_25="􀛫"
ICON_0="􀛬"
ICON_CHARGING="􀢋"

DRAWING="on"
COLOR=$COLOR_GREEN

# --- Logik für Icons & Farben ---
if [[ "$CHARGING" != "" ]]; then
  ICON=$ICON_CHARGING
  COLOR=$COLOR_GREEN
else
  if [ $PERCENTAGE -gt 80 ]; then
    ICON=$ICON_100
    COLOR=$COLOR_GREEN
  elif [ $PERCENTAGE -gt 60 ]; then
    ICON=$ICON_75
    COLOR=$COLOR_GREEN
  elif [ $PERCENTAGE -gt 40 ]; then
    ICON=$ICON_50
    COLOR=$COLOR_YELLOW
  elif [ $PERCENTAGE -gt 20 ]; then
    ICON=$ICON_25
    COLOR=$COLOR_ORANGE
  else
    ICON=$ICON_0
    COLOR=$COLOR_RED
  fi
fi

# --- Popup Click Event (Restzeit anzeigen) ---
if [ "$SENDER" = "mouse.clicked" ]; then
  # Toggle Popup
  sketchybar --set $NAME popup.drawing="toggle"
  
  # Wenn Popup geöffnet wird, Zeit berechnen
  # Wir prüfen den aktuellen Status des Popups nach dem Toggle nicht direkt, 
  # sondern aktualisieren einfach immer den Text.
  
  TIME_REMAINING=$(pmset -g batt | grep -Eo "\d+:\d+")
  if [ "$TIME_REMAINING" = "" ]; then
    TIME_REMAINING="Laden..."
  else
    TIME_REMAINING="${TIME_REMAINING}h"
  fi
  
  sketchybar --set battery.popup label="$TIME_REMAINING"
  exit 0
fi

# --- Standard Update ---
sketchybar --set $NAME drawing=$DRAWING icon="$ICON" icon.color=$COLOR label="${PERCENTAGE}%"
