#!/usr/bin/env bash

# Abort if any command fails
set -o errexit

# Archive using iPhone SDK/
xcodebuild archive -scheme $SCHEME -configuration Release -sdk iphoneos14.3 -destination "generic/platform=iOS" -archivePath $DEST/$FRAMEWORK.iphoneos.xcarchive OBJROOT=build/iOS | xcpretty
# Archive using iPhoneSimulator SDK.
xcodebuild archive -scheme $SCHEME -configuration Release -sdk iphonesimulator14.3 -destination "generic/platform=iOS Simulator" -archivePath $DEST/$FRAMEWORK.iphonesimulator.xcarchive OBJROOT=build/simulator | xcpretty
# Create XCFramework.
xcodebuild -create-xcframework -framework $DEST/$FRAMEWORK.iphoneos.xcarchive/Products/Library/Frameworks/$FRAMEWORK.framework -framework $DEST/$FRAMEWORK.iphonesimulator.xcarchive/Products/Library/Frameworks/$FRAMEWORK.framework -output $DEST/$FRAMEWORK.xcframework | xcpretty
# Remove $SCHEME prefix on symbols names (per https://developer.apple.com/forums/thread/123253)
find $DEST/$FRAMEWORK.xcframework -name "*.swiftinterface" -exec sed -i -e "s/$SCHEME\.//g" {} \;
# Delete archives.
rm -Rf $DEST/$FRAMEWORK.*.xcarchive
