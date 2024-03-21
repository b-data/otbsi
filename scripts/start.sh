#!/bin/bash
# Copyright (c) 2023 b-data GmbH.
# Distributed under the terms of the MIT License.

set -e

# Test if PREFIX location is whithin limits
if [[ ! "${PREFIX}" == "/usr/local" && ! "${PREFIX}" =~ ^"/opt" ]]; then
  echo "ERROR:  PREFIX set to '${PREFIX}'. Must either be '/usr/local' or within '/opt'."
  exit 1
fi

# Download and extract source code
curl -sSL https://www.orfeo-toolbox.org/packages/archives/OTB/OTB-${OTB_VERSION}.tar.gz \
  -o /tmp/OTB-${OTB_VERSION}.tar.gz
mkdir -p /tmp/OTB-${OTB_VERSION}
tar xfz /tmp/OTB-${OTB_VERSION}.tar.gz --no-same-owner -C /tmp/OTB-${OTB_VERSION}

# Install Shark if OTB version ≥ 9
if [[ "${OTB_VERSION%%.*}" -ge "9" ]]; then
  install-shark.sh
fi

# Install OTB
install-otb.sh
