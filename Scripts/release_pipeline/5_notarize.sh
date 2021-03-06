#!/bin/zsh

source .env

VERSION_NUMBER=`sed -n '/MARKETING_VERSION/{s/MARKETING_VERSION: //;s/;//;s/^[[:space:]]*//;p;q;}' ./project.yml`
BUILD_PATH="Build/Releases/$APP_NAME $VERSION_NUMBER.dmg"

echo "π Notarizing"
# Notarize
OUTPUT=`xcrun altool \
  -t osx -f "$BUILD_PATH" \
  --primary-bundle-id $APP_BUNDLE_IDENTIFIER \
  --notarize-app \
  -u $USERNAME \
  -p $APP_SPECIFIC_PASSWORD \
  --asc-provider "$PROVIDER_SHORTNAME"`
TICKET_PATTERN='RequestUUID = ([^\n]+)'


if [[ "$OUTPUT" =~ $TICKET_PATTERN ]]; then
  TICKET=${BASH_REMATCH[1]}
  echo "π« Ticket: $TICKET"

  echo "πΉ Waiting to check status"
  sleep 10

  DONE=0
  while [ $DONE -le 1 ]
  do
    INFO=`xcrun altool --notarization-info "$TICKET" \
    -u $USERNAME \
    -p $APP_SPECIFIC_PASSWORD`
    STATUS_MESSAGE_PATTERN='Status Message: ([^\n]+)'

    echo $INFO

    if [[ "$INFO" =~ $STATUS_MESSAGE_PATTERN ]]; then
      STATUS=${BASH_REMATCH[1]}
      if [ "$STATUS" == "Package Approved" ]; then
        echo "π¦ Package is approved"
        break
      else
        echo "π¦ Current status: $STATUS"
        sleep 10
      fi
    else
      echo "πΆββοΈ Status: in progress"
      echo $OUTPUT
      sleep 10
    fi
    done
else
  echo $OUTPUT
fi
