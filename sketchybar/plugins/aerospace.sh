#!/bin/bash

# $1 = workspace id
WORKSPACE=$1

# Apps im aktuellen Workspace abrufen
APPS=$(aerospace list-windows --workspace "$WORKSPACE" 2>/dev/null | awk -F'|' '{print $2}' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | sort -u)

ICON_LINE=""
APP_COUNT=0

if [ -n "$APPS" ]; then
  while IFS= read -r app; do
    [ -z "$app" ] && continue
    APP_COUNT=$((APP_COUNT + 1))
    
    # Füge ein Leerzeichen vor jedem neuen Icon hinzu (für Abstand)
    if [ "$APP_COUNT" -gt 1 ]; then
        ICON_LINE="${ICON_LINE} "
    fi

    case "$app" in
      *kitty*|*Alacritty*|*Terminal*|*iTerm*|*WezTerm*|*term*)
        ICON_LINE="${ICON_LINE}󰆍"
        ;;
      *Firefox*|*firefox*)
        ICON_LINE="${ICON_LINE}"
        ;;
      *Chrome*|*Google*|*chrome*|*Chromium*)
        ICON_LINE="${ICON_LINE}"
        ;;
      *Safari*|*safari*)
        ICON_LINE="${ICON_LINE}󰀹"
        ;;
      *Zen*|*zen*)
        ICON_LINE="${ICON_LINE}󰗃" # Zen Browser Icon (oder generisches Web Icon)
        ;;
      *Arc*|*arc*)
        ICON_LINE="${ICON_LINE}󰠮"
        ;;
      *Code*|*code*|*VSCode*|*vscode*)
        ICON_LINE="${ICON_LINE}󰨞"
        ;;
      *Spotify*|*spotify*)
        ICON_LINE="${ICON_LINE}"
        ;;
      *Slack*|*slack*)
        ICON_LINE="${ICON_LINE}󰒱"
        ;;
      *Discord*|*discord*)
        ICON_LINE="${ICON_LINE}󰙯"
        ;;
      *Finder*|*finder*)
        ICON_LINE="${ICON_LINE}󰀶"
        ;;
      *Music*|*music*)
        ICON_LINE="${ICON_LINE}"
        ;;
      *Notes*|*notes*)
        ICON_LINE="${ICON_LINE}󱞂"
        ;;
      *Calendar*|*calendar*)
        ICON_LINE="${ICON_LINE}"
        ;;
      *Mail*|*mail*)
        ICON_LINE="${ICON_LINE}󰇮"
        ;;
      *Messages*|*messages*)
        ICON_LINE="${ICON_LINE}󰍦"
        ;;
      *Obsidian*|*obsidian*)
        ICON_LINE="${ICON_LINE}󰠮"
        ;;
      *Notion*|*notion*)
        ICON_LINE="${ICON_LINE}󰈚"
        ;;
      *Stremio*|*stremio*)
        ICON_LINE="${ICON_LINE}󰎁"
        ;;
      *)
        # Fallback Icon für unbekannte Apps
        ICON_LINE="${ICON_LINE}"
        ;;
    esac
  done <<< "$APPS"
fi

# Placeholder, wenn leer
if [ "$APP_COUNT" -eq 0 ]; then
  ICON_LINE=" —"
fi

# Status Update an Sketchybar senden
if [ "$WORKSPACE" = "$FOCUSED_WORKSPACE" ]; then
  sketchybar --set "space.$WORKSPACE" \
    icon.highlight=on \
    label.highlight=on \
    label="$ICON_LINE" \
    background.border_color=0xff76cce0
else
  sketchybar --set "space.$WORKSPACE" \
    icon.highlight=off \
    label.highlight=off \
    label="$ICON_LINE" \
    background.border_color=0xff414550
fi
