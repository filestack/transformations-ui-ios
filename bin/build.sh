#!/usr/bin/env bash

# Abort if any command fails
set -o errexit

DIR=$(cd `dirname $0` && pwd)
DEST=export

rm -Rf $DEST
mkdir $DEST

SCHEME=TransformationsUI FRAMEWORK=TransformationsUI DEST=export $DIR/build-xcframework.sh
SCHEME=TransformationsUIShared FRAMEWORK=TransformationsUIShared DEST=export $DIR/build-xcframework.sh
SCHEME=TransformationsUIPremiumAddOns FRAMEWORK=TransformationsUIPremiumAddOns DEST=export $DIR/build-xcframework.sh
SCHEME=UberSegmentedControl FRAMEWORK=UberSegmentedControl DEST=export $DIR/build-xcframework.sh
SCHEME=Pikko FRAMEWORK=Pikko DEST=export $DIR/build-xcframework.sh