#!/bin/bash
# Copyright (c) 2025 b-data GmbH.
# Distributed under the terms of the MIT License.

set -e

mkdir /var/cache/swig-build
pushd /var/cache/swig-build > /dev/null

# Download and extract source code
curl -sSLO https://netcologne.dl.sourceforge.net/project/swig/swig/swig-4.2.1/swig-4.2.1.tar.gz
tar xfz swig-4.2.1.tar.gz --no-same-owner
cd swig-4.2.1

# Configure
./configure

# Build
make

# Install
make install

popd > /dev/null
