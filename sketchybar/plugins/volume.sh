#!/bin/bash

# --- Icons ---
ICON_100="􀊩"  # speaker.wave.3.fill
ICON_66="􀊧"   # speaker.wave.2.fill
ICON_33="􀊥"   # speaker.wave.1.fill
ICON_10="􀊣"   # speaker.fill
ICON_0="􀊡"    # speaker.slash.fill

# --- Volume Update (wird bei volume_change aufgerufen) ---
if [ "$SENDER" = "volume_change" ]; then
  VOLUME=$INFO
  
  if [ "$VOLUME" -gt 60 ]; then
    ICON=$ICON_100
  elif [ "$VOLUME" -gt 30 ]; then
    ICON=$ICON_66
  elif [ "$VOLUME" -gt 10 ]; then
    ICON=$ICON_33
  elif [ "$VOLUME" -gt 0 ]; then
    ICON=$ICON_10
  else
    ICON=$ICON_0
  fi

  sketchybar --set $NAME icon="$ICON" label="$VOLUME%" \
             --set volume.slider slider.percentage=$VOLUME
fi

# --- Click Event (Öffnet Popup & lädt Geräte) ---
if [ "$SENDER" = "mouse.clicked" ]; then 
  # 1. Popup toggeln
  sketchybar --set $NAME popup.drawing="toggle"

  # 2. Wenn Popup offen ist, Geräte laden
  DRAWING=$(sketchybar --query $NAME | jq -r ".popup.drawing")
  
  if [ "$DRAWING" = "on" ]; then
    # Alte Geräte aus der Liste löschen (Clean up)
    sketchybar --remove '/volume.device\.*/'

    # Aktuelles Gerät finden
    CURRENT=$(SwitchAudioSource -t output -c)
    
    # Durch alle Geräte loopen und hinzufügen
    COUNTER=0
    SwitchAudioSource -a -t output | while read -r DEVICE; do
      COLOR=0xffcdd6f4
      if [ "$DEVICE" = "$CURRENT" ]; then
        COLOR=0xffa6da95 # Grün für aktives Gerät
      fi
      
      sketchybar --add item volume.device.$COUNTER popup.$NAME \
                 --set volume.device.$COUNTER label="$DEVICE" \
                       label.color=$COLOR \
                       click_script="SwitchAudioSource -s \"$DEVICE\" && sketchybar --set /volume.device\.*/ label.color=0xffcdd6f4 --set \$NAME label.color=0xffa6da95 --set $NAME popup.drawing=off"
      COUNTER=$((COUNTER+1))
    done
  fi
fi

# --- Slider Event (Wenn man den Regler zieht) ---
if [ "$SENDER" = "mouse.clicked" ] && [ "$NAME" = "volume.slider" ]; then
  osascript -e "set volume output volume $PERCENTAGE"
fi

# --- Scroll Event (Lautstärke ändern mit Mausrad) ---
if [ "$SENDER" = "mouse.scrolled" ]; then
  # SENSITIVITY anpassen: ohne modifier normal, mit shift schneller
  DELTA=$SCROLL_DELTA
  osascript -e "set volume output volume (output volume of (get volume settings) + $DELTA)"
fi
