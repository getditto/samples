#!/bin/bash

set -euxo pipefail

DITTOSYNCKIT_VERSION=2.0.0-alpha1
echo "Downloading DittoSyncKit version: $DITTOSYNCKIT_VERSION"

rm -f DittoSyncKit.tar.gz
rm -f libditto.a
rm -f DittoSyncKit.h

curl -O https://software.ditto.live/cpp-ios/Ditto/$DITTOSYNCKIT_VERSION/dist/Ditto.tar.gz && tar xvfz Ditto.tar.gz

echo "Successfully downloaded DittoSyncKit version: $DITTOSYNCKIT_VERSION"
