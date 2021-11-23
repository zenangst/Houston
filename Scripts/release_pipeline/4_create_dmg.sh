#!/bin/zsh

source .env
echo $APP_NAME
# Create a .dmg
create-dmg "Build/Releases/$APP_NAME.app" \
  --overwrite \
  --dmg-title="$APP_NAME" \
  Build/Releases
