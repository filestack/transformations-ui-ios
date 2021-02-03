#!/bin/bash

# Abort if any command fails
set -o errexit

# Pass scheme name as the first argument to the script
NAME=$1
SRCROOT=$2
DEST=$3
REMOVEPREFIX=$4

# Build the scheme for all platforms that we plan to support
for PLATFORM in "iOS" "iOS Simulator"; do

    case $PLATFORM in
    "iOS")
    RELEASE_FOLDER="Release-iphoneos"
    ;;
    "iOS Simulator")
    RELEASE_FOLDER="Release-iphonesimulator"
    ;;
    esac

    ARCHIVE_PATH=$DEST/$NAME-$RELEASE_FOLDER

    # Rewrite Package.swift so that it declaras dynamic libraries, since the approach does not work with static libraries
    perl -i -p0e 's/type: .static,//g' $SRCROOT/Package.swift
    perl -i -p0e 's/type: .dynamic,//g' $SRCROOT/Package.swift
    perl -i -p0e 's/(library[^,]*,)/$1 type: .dynamic,/g' $SRCROOT/Package.swift

    xcodebuild archive -workspace $SRCROOT -scheme $NAME \
            -destination "generic/platform=$PLATFORM" \
            -archivePath $ARCHIVE_PATH \
            -derivedDataPath "$SRCROOT/.build" \
            SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES

    FRAMEWORK_PATH="$ARCHIVE_PATH.xcarchive/Products/usr/local/lib/$NAME.framework"
    MODULES_PATH="$FRAMEWORK_PATH/Modules"
    mkdir -p $MODULES_PATH

    BUILD_PRODUCTS_PATH="$SRCROOT/.build/Build/Intermediates.noindex/ArchiveIntermediates/$NAME/BuildProductsPath"
    RELEASE_PATH="$BUILD_PRODUCTS_PATH/$RELEASE_FOLDER"
    SWIFT_MODULE_PATH="$RELEASE_PATH/$NAME.swiftmodule"
    RESOURCES_BUNDLE_PATH="$RELEASE_PATH/${NAME}_${NAME}.bundle"

    # Copy Swift modules
    if [ -d $SWIFT_MODULE_PATH ]
    then
        cp -r $SWIFT_MODULE_PATH $MODULES_PATH
    else
        # In case there are no modules, assume C/ObjC library and create module map
        echo "module $NAME { export * }" > $MODULES_PATH/module.modulemap
        # TODO: Copy headers
    fi

    # Copy resources bundle, if exists
    if [ -e $RESOURCES_BUNDLE_PATH ]
    then
        cp -r $RESOURCES_BUNDLE_PATH $FRAMEWORK_PATH
    fi
done

if [ -d $DEST/$NAME.xcframework ]
then
    rm -Rf $DEST/$NAME.xcframework
fi

xcodebuild -create-xcframework \
-framework $DEST/$NAME-Release-iphoneos.xcarchive/Products/usr/local/lib/$NAME.framework \
-framework $DEST/$NAME-Release-iphonesimulator.xcarchive/Products/usr/local/lib/$NAME.framework \
-output $DEST/$NAME.xcframework

if [ -d $DEST/$NAME-Release-iphoneos.xcarchive ]
then
    rm -Rf $DEST/$NAME-Release-iphoneos.xcarchive
fi

if [ -d $DEST/$NAME-Release-iphonesimulator.xcarchive ]
then
    rm -Rf $DEST/$NAME-Release-iphonesimulator.xcarchive
fi

if [[ -z "${REMOVEPREFIX}" ]]
then
    # Remove $NAME prefix on symbols names (per https://developer.apple.com/forums/thread/123253)
    find $DEST/$NAME.xcframework -name "*.swiftinterface" -exec sed -i -e "s/$NAME\.//g" {} \;
fi
