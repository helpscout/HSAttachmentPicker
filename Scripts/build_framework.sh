#!/usr/bin/env bash
set -euo pipefail

# clean up the /build folder so we don't have anything stale there
rm -rf build
rm -rf HSAttachmentPicker.xcframework 

# build HSAttachmentPicker for the simulator specifying the project file & move the dsysm to the appropriate place
xcodebuild archive -project HSAttachmentPicker.xcodeproj -scheme HSAttachmentPicker -configuration Release -destination 'generic/platform=iOS Simulator' -archivePath $(PWD)/build/HSAttachmentPicker.framework-iphonesimulator.xcarchive SKIP_INSTALL=NO | xcpretty -f `xcpretty-travis-formatter`

# build HSAttachmentPicker for device specifying the project file
xcodebuild archive -project HSAttachmentPicker.xcodeproj -scheme HSAttachmentPicker -configuration Release -destination 'generic/platform=iOS' -archivePath $(PWD)/build/HSAttachmentPicker.framework-iphoneos.xcarchive SKIP_INSTALL=NO | xcpretty -f `xcpretty-travis-formatter`