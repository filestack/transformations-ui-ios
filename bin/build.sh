#!/bin/bash

# Abort if any command fails
set -o errexit

DIR=$(dirname "$0")
DEST=$(dirname "$DIR")/artifacts

rm -Rf $DEST/*.xcarchive $DEST/*.xcframework

# Build all the required binary dependencies.
for PACKAGE in "TransformationsUIShared" "TransformationsUIPremiumAddOns" "UberSegmentedControl" "Pikko"; do

    case $PACKAGE in
    "TransformationsUIShared")
    REPO="transformations-ui-shared-ios"
    OWNER="filestack"
    ;;
    "TransformationsUIPremiumAddOns")
    REPO="transformations-ui-premium-addons-ios"
    OWNER="filestack"
    ;;
    "UberSegmentedControl")
    REPO="UberSegmentedControl"
    OWNER="rnine"
    ;;
    "Pikko")
    REPO="pikko"
    OWNER="rnine"
    ;;
    esac

    GITURL="git@github.com:$OWNER/$REPO.git"

    if [ -d $DEST/work/$REPO ]
    then
        rm -Rf $DEST/work/$REPO
    fi

    git clone $GITURL $DEST/work/$REPO
    TAG=$(cd $DEST/work/$REPO && git tag | sort -r | head -n 1)
    (cd $DEST/work/$REPO && git checkout $TAG)

    $DIR/generate-xcframework.sh $PACKAGE $DEST/work/$REPO $DEST | xcpretty

    if [ -d $DEST/work/$REPO ]
    then
        rm -Rf $DEST/work/$REPO
    fi
done

if [ -d $DEST/work ]
then
    rm -Rf $DEST/work
fi
