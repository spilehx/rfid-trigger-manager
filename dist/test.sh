#!/usr/bin/env bash

TRACK_URI="spotify:track:3n3Ppam7vgaVa1iaRUc9Lp"

init() {
  if isMopidyRunning; then
    echo "Mopidy is running. Stopping Mopidy..."
    stopMopidy
  else
    echo "Mopidy is not running. Starting Mopidy..."
    startMopidy
    # sleep 5
    # playSpotify
  fi
}

isMopidyRunning() {
  if pgrep -x "mopidy" >/dev/null 2>&1; then
    return 0
  else
    return 1
  fi
}

startMopidy() {
  nohup mopidy >/dev/null 2>&1 &
  echo "Mopidy started as a background daemon."
}

stopMopidy() {
  pkill "mopidy" && echo "Mopidy stopped." || echo "Failed to stop Mopidy or it was not running."
}

playSpotify() {
  echo "Playing Spotify..."
  mpc -h 127.0.0.1 clear && mpc add "$TRACK_URI" && mpc play
}

init
