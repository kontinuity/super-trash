#!/bin/sh

cd ..

# Clean build directories
rm -rf build

# Build app
xcodebuild -project SuperTrash.xcodeproj -alltargets

# Update Info.plist with TM_BUILD_DATE
ruby update_build_date.rb

cd packaging
if [[ "$*" =~ "--dmg" ]]
then
  # Package into DMG
  ./make-diskimage.sh supertrash.dmg ../build/Release SuperTrash dmg.applescript .
else
  echo 'DMG build skipped'
fi

cd ..
if [[ "$*" =~ "--appcast" ]]
then
  # Build Sparkle app cast  
  ruby appcast_automation.rb
else
  echo 'Sparkle appcast skipped'
fi

cd packaging
