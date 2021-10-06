#!/usr/bin/env bash
set -euo pipefail

# Attemping to pass build/#{CONGIGURATION}/HSAttachmentPicker.framework.dSYM causes an error that it's an invalid dSYM hence the $(PWD), filed here FB8339148
xcodebuild -create-xcframework -framework $(PWD)/build/HSAttachmentPicker.framework-iphoneos.xcarchive/Products/Library/Frameworks/HSAttachmentPicker.framework -debug-symbols $(PWD)/build/HSAttachmentPicker.framework-iphoneos.xcarchive/dSYMs/HSAttachmentPicker.framework.dSYM -framework $(PWD)/build/HSAttachmentPicker.framework-iphonesimulator.xcarchive/Products/Library/Frameworks/HSAttachmentPicker.framework -debug-symbols $(PWD)/build/HSAttachmentPicker.framework-iphonesimulator.xcarchive/dSYMs/HSAttachmentPicker.framework.dSYM -output HSAttachmentPicker.xcframework
