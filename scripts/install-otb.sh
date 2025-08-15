#!/bin/bash
# Copyright (c) 2023 b-data GmbH.
# Distributed under the terms of the MIT License.

set -e

if [ "${OTB_VERSION%%.*}" -ge "9" ]; then
  # Configure
  cmake \
    -DModule_S1TilingSupportApplications=ON \
    -DModule_SertitObject=ON \
    -DModule_otbGRM=ON \
    -DModule_OTBTemporalGapFilling=ON \
    -DOTB_BUILD_FeaturesExtraction=${OTB_BUILD_FEATURES_EXTRACTION} \
    -DOTB_BUILD_Hyperspectral=${OTB_BUILD_HYPERSPECTRAL} \
    -DOTB_BUILD_Learning=${OTB_BUILD_LEARNING} \
    -DOTB_BUILD_Miscellaneous=${OTB_BUILD_MISCELLANEOUS} \
    -DOTB_BUILD_SAR=${OTB_BUILD_SAR} \
    -DOTB_BUILD_Segmentation=${OTB_BUILD_SEGMENTATION} \
    -DOTB_BUILD_StereoProcessing=${OTB_BUILD_STEREO_PROCESSING} \
    -DOTB_USE_6S=${OTB_USE_6S} \
    -DOTB_USE_CURL=${USE_SYSTEM_CURL} \
    -DOTB_USE_GSL=${USE_SYSTEM_GSL} \
    -DOTB_USE_LIBKML=${USE_SYSTEM_LIBKML} \
    -DOTB_USE_LIBSVM=${USE_SYSTEM_LIBSVM} \
    -DOTB_USE_MUPARSER=${USE_SYSTEM_MUPARSER} \
    -DOTB_USE_MUPARSERX=${USE_SYSTEM_MUPARSERX} \
    -DOTB_USE_OPENCV=${USE_SYSTEM_OPENCV} \
    -DOTB_USE_SHARK=ON \
    -DOTB_USE_SIFTFAST=${OTB_USE_SIFTFAST} \
    -DOTB_WRAP_PYTHON=${OTB_WRAP_PYTHON} \
    -DOTB_WRAP_QGIS=${OTB_WRAP_QGIS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_POLICY_DEFAULT_CMP0135=NEW \
    /tmp/OTB-${OTB_VERSION}

    if [ "${MODE}" = "install" ]; then
      # Build
      make -j

      # Install
      make install
    fi
else
  # Configure
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
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_POLICY_DEFAULT_CMP0135=NEW \
    /tmp/OTB-${OTB_VERSION}/SuperBuild

  if [ "${MODE}" = "install" ]; then
    make -j

    # Install DiapOTB module if OTB version < 8
    CMAKE_EXTRA_ARGS=()

    if [ "${OTB_VERSION%%.*}" -lt "8" ]; then
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

    make -j
  fi
fi

# Generate application descriptor files for QGIS Processing Plugins
# DiapOTBModule: Generated automatically during installation
if [ "${MODE}" = "install" ]; then
  if dpkg --compare-versions "$OTB_VERSION" lt "9.1.1"; then
    # S1TilingSupportApplications
    ${PREFIX}/bin/otbQgisDescriptor MultitempFilteringFilter \
      ${PREFIX}/lib/otb/applications \
      ${PREFIX}/share/otb/description/
    ${PREFIX}/bin/otbQgisDescriptor MultitempFilteringOutcore \
      ${PREFIX}/lib/otb/applications \
      ${PREFIX}/share/otb/description/
    # SertitObject
    ${PREFIX}/bin/otbQgisDescriptor Aggregate \
      ${PREFIX}/lib/otb/applications \
      ${PREFIX}/share/otb/description/
    ${PREFIX}/bin/otbQgisDescriptor ObjectsRadiometricStatistics \
      ${PREFIX}/lib/otb/applications \
      ${PREFIX}/share/otb/description/
    # otbGRM
    ${PREFIX}/bin/otbQgisDescriptor GenericRegionMerging \
      ${PREFIX}/lib/otb/applications \
      ${PREFIX}/share/otb/description/
    # OTBTemporalGapFilling
    ${PREFIX}/bin/otbQgisDescriptor ImageTimeSeriesGapFilling \
      ${PREFIX}/lib/otb/applications \
      ${PREFIX}/share/otb/description/
  else
    printf 'MultitempFilteringFilter\nMultitempFilteringOutcore\nAggregate\nObjectsRadiometricStatistics\nGenericRegionMerging\nImageTimeSeriesGapFilling\n' \
      > /tmp/algos.txt
    ${PREFIX}/bin/otbQgisDescriptor /tmp/algos.txt \
      ${PREFIX}/lib/otb/applications \
      ${PREFIX}/share/otb/description/
  fi
fi
