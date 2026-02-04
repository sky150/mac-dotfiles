#!/bin/bash

# --- Icons ---
ICON_WIFI="􀙇"
ICON_ETHERNET="􀈂" # Ein Kabel-Symbol
ICON_DISCONNECTED="􀙈"

# --- 1. Welches Interface hat Internet? ---
# Wir fragen die Routing-Tabelle: "Wer bringt mich zu Google (8.8.8.8)?"
ACTIVE_IF=$(route get 8.8.8.8 2>/dev/null | awk '/interface: / {print $2}')

# --- 2. Update Routine ---
if [ "$SENDER" = "wifi_change" ] || [ "$SENDER" = "forced" ] || [ "$SENDER" = "routine" ] || [ "$SENDER" = "mouse.clicked" ]; then

  if [ -z "$ACTIVE_IF" ]; then
    # --> GAR KEIN INTERNET
    sketchybar --set wifi icon="$ICON_DISCONNECTED" label="Offline" icon.color=0xffed8796
  
  elif [ "$ACTIVE_IF" = "en0" ]; then
    # --> ES IST WLAN (en0)
    # Versuche SSID über das Airport Tool zu holen
    AIRPORT_CMD="/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport"
    SSID=$("$AIRPORT_CMD" -I | awk -F': ' '/ SSID/{print $2}' | xargs)
    
    if [ -z "$SSID" ]; then SSID="Wi-Fi"; fi
    
    sketchybar --set wifi icon="$ICON_WIFI" label="$SSID" icon.color=0xffa6da95

  else
    # --> ES IST ETWAS ANDERES (Kabel, Dock, iPhone USB)
    # Wir nennen es einfach "Wired" oder zeigen den Interface-Namen
    sketchybar --set wifi icon="$ICON_ETHERNET" label="Ethernet ($ACTIVE_IF)" icon.color=0xff8aadf4
  fi
fi

# --- 3. Popup Logic (Details) ---
if [ "$SENDER" = "mouse.clicked" ]; then
  if [ "$NAME" = "wifi" ]; then
    sketchybar --set wifi popup.drawing="toggle"
    
    if [ "$(sketchybar --query wifi | jq -r '.popup.drawing')" = "on" ]; then
      # IP von dem Interface holen, das wirklich aktiv ist
      IP=$(ipconfig getifaddr "$ACTIVE_IF")
      
      # Router Info
      ROUTER=$(netstat -rn | grep default | grep "$ACTIVE_IF" | awk '{print $2}' | head -1)
      
      if [ -z "$IP" ]; then IP="No IP"; fi
      
      sketchybar --set wifi.ip label="$IP" \
                 --set wifi.router label="$ROUTER" \
                 --set wifi.mask label="Interface: $ACTIVE_IF"
    fi
  else
    # Copy Logic
    LABEL=$(sketchybar --query "$NAME" | jq -r ".label.value")
    echo "$LABEL" | pbcopy
    sketchybar --set "$NAME" label="Copied!"
    sleep 1
    sketchybar --set "$NAME" label="$LABEL"
  fi
fi

if [ "$SENDER" = "mouse.exited.global" ]; then
  sketchybar --set wifi popup.drawing=off
fi
