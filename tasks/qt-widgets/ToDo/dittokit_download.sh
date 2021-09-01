#!/bin/bash

set -euxo pipefail

PROJECT_ROOT_DIR=`git rev-parse --show-toplevel`

DITTOSYNCKIT_VERSION=0.1.0
echo "Downloading DittoSyncKit version: $DITTOSYNCKIT_VERSION"

DITTOSYNCKIT_FILENAME=DittoSyncKit.tar.gz

rm -f $PROJECT_ROOT_DIR/qt-widgets/ToDo/DittoSyncKit.tar.gz
rm -f $PROJECT_ROOT_DIR/qt-widgets/ToDo/libditto.a
rm -f $PROJECT_ROOT_DIR/qt-widgets/ToDo/DittoSyncKit.h

wget "https://software.ditto.live/cpp-ios/DittoSyncKit/$DITTOSYNCKIT_VERSION/dist/$DITTOSYNCKIT_FILENAME" -P $PROJECT_ROOT_DIR/qt-widgets/ToDo
tar xvfz $PROJECT_ROOT_DIR/qt-widgets/ToDo/$DITTOSYNCKIT_FILENAME -C $PROJECT_ROOT_DIR/qt-widgets/ToDo

echo "Successfully downloaded DittoSyncKit version: $DITTOSYNCKIT_VERSION"
