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
curl -sSL https://www.orfeo-toolbox.org/packages/archives/OTB/OTB-$OTB_VERSION.tar.gz \
  -o /tmp/OTB-$OTB_VERSION.tar.gz
mkdir -p /tmp/OTB-$OTB_VERSION
tar xfz /tmp/OTB-$OTB_VERSION.tar.gz --no-same-owner -C /tmp/OTB-$OTB_VERSION

# Build and install
cmake \
  -DUSE_SYSTEM_BOOST=${USE_SYSTEM_BOOST} \
  -DUSE_SYSTEM_CURL=${USE_SYSTEM_CURL} \
  -DUSE_SYSTEM_EXPAT=${USE_SYSTEM_EXPAT} \
  -DUSE_SYSTEM_FFTW=${USE_SYSTEM_FFTW} \
  -DUSE_SYSTEM_FREETYPE=${USE_SYSTEM_FREETYPE} \
  -DUSE_SYSTEM_GDAL=${USE_SYSTEM_GDAL} \
  -DUSE_SYSTEM_GEOS=${USE_SYSTEM_GEOS} \
  -DUSE_SYSTEM_GEOTIFF=${USE_SYSTEM_GEOTIFF} \
  -DUSE_SYSTEM_GLEW=${USE_SYSTEM_GLEW} \
  -DUSE_SYSTEM_GLFW=${USE_SYSTEM_GLFW} \
  -DUSE_SYSTEM_GLUT=${USE_SYSTEM_GLUT} \
  -DUSE_SYSTEM_GSL=${USE_SYSTEM_GSL} \
  -DUSE_SYSTEM_HDF4=${USE_SYSTEM_HDF4} \
  -DUSE_SYSTEM_HDF5=${USE_SYSTEM_HDF5} \
  -DUSE_SYSTEM_ITK=${USE_SYSTEM_ITK} \
  -DUSE_SYSTEM_JPEG=${USE_SYSTEM_JPEG} \
  -DUSE_SYSTEM_LIBKML=${USE_SYSTEM_LIBKML} \
  -DUSE_SYSTEM_LIBSVM=${USE_SYSTEM_LIBSVM} \
  -DUSE_SYSTEM_MUPARSER=${USE_SYSTEM_MUPARSER} \
  -DUSE_SYSTEM_MUPARSERX=${USE_SYSTEM_MUPARSERX} \
  -DUSE_SYSTEM_NETCDF=${USE_SYSTEM_NETCDF} \
  -DUSE_SYSTEM_OPENCV=${USE_SYSTEM_OPENCV} \
  -DUSE_SYSTEM_OPENJPEG=${USE_SYSTEM_OPENJPEG} \
  -DUSE_SYSTEM_OPENSSL=${USE_SYSTEM_OPENSSL} \
  -DUSE_SYSTEM_OPENTHREADS=${USE_SYSTEM_OPENTHREADS} \
  -DUSE_SYSTEM_OSSIM=${USE_SYSTEM_OSSIM} \
  -DUSE_SYSTEM_PCRE=${USE_SYSTEM_PCRE} \
  -DUSE_SYSTEM_PNG=${USE_SYSTEM_PNG} \
  -DUSE_SYSTEM_PROJ=${USE_SYSTEM_PROJ} \
  -DUSE_SYSTEM_QT5=${USE_SYSTEM_QT5} \
  -DUSE_SYSTEM_QWT=${USE_SYSTEM_QWT} \
  -DUSE_SYSTEM_SHARK=${USE_SYSTEM_SHARK} \
  -DUSE_SYSTEM_SQLITE=${USE_SYSTEM_SQLITE} \
  -DUSE_SYSTEM_SWIG=${USE_SYSTEM_SWIG} \
  -DUSE_SYSTEM_TIFF=${USE_SYSTEM_TIFF} \
  -DUSE_SYSTEM_TINYXML=${USE_SYSTEM_TINYXML} \
  -DUSE_SYSTEM_ZLIB=${USE_SYSTEM_ZLIB} \
  -DOTB_WRAP_PYTHON=${OTB_WRAP_PYTHON} \
  -DOTB_WRAP_QGIS=${OTB_WRAP_QGIS} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  /tmp/OTB-$OTB_VERSION/SuperBuild

if [ "${MODE}" = "install" ]; then
  make -j
fi

# Install DiapOTB module if OTB version < 8
CMAKE_EXTRA_ARGS=()

if [[ "${OTB_VERSION}" < "8" ]]; then
  CMAKE_EXTRA_ARGS+=(
    "-DModule_DiapOTBModule=ON"
  )
fi

# Build and install remote modules
cmake \
  -DModule_S1TilingSupportApplications=ON \
  -DModule_SertitObject=ON \
  -DModule_otbGRM=ON \
  -DModule_OTBTemporalGapFilling=ON \
  "${CMAKE_EXTRA_ARGS[@]}" \
  OTB/build

if [ "${MODE}" = "install" ]; then
  make -j
fi
