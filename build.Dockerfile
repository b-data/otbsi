ARG IMAGE
ARG PREFIX=/usr/local

FROM ${IMAGE} as builder

ARG DEBIAN_FRONTEND=noninteractive

ARG OTB_VERSION

ARG USE_SYSTEM_BOOST=ON
ARG USE_SYSTEM_CURL=ON
ARG USE_SYSTEM_EXPAT=ON
ARG USE_SYSTEM_FFTW=ON
ARG USE_SYSTEM_FREETYPE=ON
ARG USE_SYSTEM_GDAL=ON
ARG USE_SYSTEM_GEOS=ON
ARG USE_SYSTEM_GEOTIFF=ON
ARG USE_SYSTEM_GLEW=ON
ARG USE_SYSTEM_GLFW=ON
ARG USE_SYSTEM_GLUT=ON
ARG USE_SYSTEM_GSL=ON
ARG USE_SYSTEM_HDF4=ON
ARG USE_SYSTEM_HDF5=ON
ARG USE_SYSTEM_ITK=ON
ARG USE_SYSTEM_JPEG=ON
ARG USE_SYSTEM_LIBKML=ON
ARG USE_SYSTEM_LIBSVM=ON
ARG USE_SYSTEM_MUPARSER=ON
ARG USE_SYSTEM_MUPARSERX=ON
ARG USE_SYSTEM_NETCDF=ON
ARG USE_SYSTEM_OPENCV=ON
ARG USE_SYSTEM_OPENJPEG=ON
ARG USE_SYSTEM_OPENSSL=ON
ARG USE_SYSTEM_OPENTHREADS=ON
ARG USE_SYSTEM_OSSIM=ON
ARG USE_SYSTEM_PCRE=ON
ARG USE_SYSTEM_PNG=ON
ARG USE_SYSTEM_PROJ=ON
ARG USE_SYSTEM_QT5=ON
ARG USE_SYSTEM_QWT=ON
ARG USE_SYSTEM_SHARK=OFF
ARG USE_SYSTEM_SQLITE=ON
ARG USE_SYSTEM_SWIG=ON
ARG USE_SYSTEM_TIFF=ON
ARG USE_SYSTEM_TINYXML=ON
ARG USE_SYSTEM_ZLIB=ON
ARG OTB_WRAP_PYTHON=ON
ARG OTB_WRAP_QGIS=ON

ARG PREFIX
ARG MODE=install

ENV CC=/usr/lib/ccache/gcc \
    CXX=/usr/lib/ccache/g++ \
    LANG=C.UTF-8 \
    PATH=/usr/lib/ccache:$PATH

## Install system dependencies
RUN if [ "$(uname -m)" = "x86_64" ]; then \
    apt-get update; \
    apt-get -y install \
      apt-transport-https \
      bzip2 \
      ca-certificates \
      ccache \
      cmake \
      curl \
      dirmngr \
      g++ \
      gcc \
      git \
      make \
      nano \
      patch \
      pkg-config \
      python3-dev \
      python3-numpy \
      python3-pip \
      python3-setuptools \
      lsb-release \
      software-properties-common \
      swig \
      unzip \
      vim \
      wget \
      zip; \
  fi

## Install build dependencies (codename-independent)
RUN if [ "$(uname -m)" = "x86_64" ]; then \
    apt-get -y install \
      freeglut3-dev \
      libboost-date-time-dev \
      libboost-filesystem-dev \
      libboost-graph-dev \
      libboost-program-options-dev \
      libboost-system-dev \
      libboost-thread-dev \
      libcurl4-gnutls-dev \
      libexpat1-dev \
      libfftw3-dev \
      libgdal-dev \
      libgeotiff-dev \
      libglew-dev \
      libglfw3-dev \
      libgsl-dev \
      libinsighttoolkit4-dev \
      libkml-dev \
      libmuparser-dev \
      libmuparserx-dev \
      libopencv-core-dev \
      libopencv-ml-dev \
      libopenthreads-dev \
      libpng-dev \
      libqt5opengl5-dev \
      libqwt-qt5-dev \
      libsvm-dev \
      libtinyxml-dev \
      qtbase5-dev \
      qttools5-dev \
      default-jdk \
      python3-gdal \
      python3-setuptools \
      libxmu-dev \
      libxi-dev \
      qttools5-dev-tools \
      bison \
      gdal-bin; \
  fi

## Install build dependencies (codename-dependent)
RUN if [ "$(uname -m)" = "x86_64" ]; then \
    . /etc/os-release; \
    if $(echo $VERSION_CODENAME | grep -Eq "buster|bullseye|focal"); then \
      apt-get -y install \
        libossim-dev; \
    fi \
  fi

COPY scripts/start.sh /usr/bin/

WORKDIR /var/cache/otb-build

RUN if [ "$(uname -m)" = "x86_64" ]; then \
    start.sh; \
  else \
    mkdir -p ${PREFIX}; \
    echo "Orfeo Toolbox (OTB) is only available for linux/amd64." > \
      ${PREFIX}/OTB_INFO.txt; \
  fi

FROM scratch

LABEL org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.source="https://gitlab.b-data.ch/orfeotoolbox/otbsi" \
      org.opencontainers.image.vendor="b-data GmbH" \
      org.opencontainers.image.authors="Olivier Benz <olivier.benz@b-data.ch>"

ARG PREFIX

COPY --from=builder ${PREFIX} ${PREFIX}
