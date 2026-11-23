#!/bin/sh
# Dia settings kept in macOS defaults (the rest of Dia's settings sync with your Dia account).
# Run while Dia is closed, or Dia overwrites them when it quits.
set -eu
defaults write company.thebrowser.dia autoCleanInactiveTabsEnabled -bool false
defaults write company.thebrowser.dia autoCleanInactiveTabsThreshold -string twelveHours
defaults write company.thebrowser.dia nativeAdBlockEnabled -bool true
