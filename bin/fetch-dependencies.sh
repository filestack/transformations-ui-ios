#!/usr/bin/env bash

# Abort if any command fails
set -o errexit

DIR=$(cd `dirname $0` && pwd)
DEST=dependencies

rm -Rf $DEST
mkdir $DEST

REPO=transformations-ui-shared-ios
git clone -b 1.1.0 --depth 1 git@github.com:filestack/$REPO.git dependencies/$REPO

REPO=transformations-ui-premium-addons-ios
git clone -b 1.1.0 --depth 1 git@github.com:filestack/$REPO.git dependencies/$REPO

REPO=UberSegmentedControl
git clone -b 1.3.2 --depth 1 git@github.com:rnine/$REPO.git dependencies/$REPO

REPO=pikko
git clone -b 1.0.8 --depth 1 git@github.com:rnine/$REPO.git dependencies/$REPO