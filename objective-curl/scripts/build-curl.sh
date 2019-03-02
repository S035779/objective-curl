#!/bin/bash
set -euC

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

OSX_SDK_VERSION="MacOSX10.14.sdk"
OSX_VERSION="10.13.6"
OSX_SDK_PATH="/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/${OSX_SDK_VERSION}"

export CFLAGS="-O -g -isysroot ${OSX_SDK_PATH} -mmacosx-version-min=${OSX_VERSION} -arch x86_64"

ZLIB_BUILD="zlib-1.2.11"
OSSL_BUILD="openssl-1.1.1b"
SSH2_BUILD="libssh2-1.8.1-20190228"
CURL_BUILD="curl-7.64.1-20190228"

ZLIB_DIR="libz"
ZLIB_INCLUDE="${SCRIPT_DIR}/${ZLIB_DIR}/include"
ZLIB_LIBS="${SCRIPT_DIR}/${ZLIB_DIR}/lib"

OSSL_DIR="openssl"
OSSL_INCLUDE="${SCRIPT_DIR}/${OSSL_DIR}/include"
OSSL_LIBS="${SCRIPT_DIR}/${OSSL_DIR}/lib"

SSH2_DIR="libssh2"
SSH2_INCLUDE="${SCRIPT_DIR}/${SSH2_DIR}/include"
SSH2_LIBS="${SCRIPT_DIR}/${SSH2_DIR}/lib"

PROJECT_LIBS="${SCRIPT_DIR}/../../lib"
PROJECT_INCLUDE="${SCRIPT_DIR}/../../include"

###
echo +++++++++++++++++++++++++
echo +++++ ${ZLIB_BUILD} +++++
echo +++++++++++++++++++++++++
###

cd ${SCRIPT_DIR}

if [ -d ${ZLIB_DIR} ]; then
  rm -rf ${ZLIB_DIR}
fi

if [ -d ${ZLIB_BUILD} ]; then
  rm -rf ${ZLIB_BUILD}
fi

# Ecxtract zlib source
curl -L http://zlib.net/${ZLIB_BUILD}.tar.gz -o ${ZLIB_BUILD}.tar.gz
tar zxvf ${ZLIB_BUILD}.tar.gz

# Change to the source dir
cd ${ZLIB_BUILD}

# Build zlib
./configure --static \
            --prefix=${SCRIPT_DIR}/${ZLIB_DIR}
make
make install

# Copy the static lib into the project directory
ZLIB_STATIC_LIB_FILE="${ZLIB_LIBS}/libz.a"

echo "Copying ${ZLIB_STATIC_LIB_FILE} => ${PROJECT_LIBS}"
cp ${ZLIB_STATIC_LIB_FILE} ${PROJECT_LIBS}

###
echo +++++++++++++++++++++++++
echo +++++ ${OSSL_BUILD} +++++
echo +++++++++++++++++++++++++
###

cd ${SCRIPT_DIR}

if [ -d ${OSSL_DIR} ]; then
  rm -rf ${OSSL_DIR}
fi

if [ -d ${OSSL_BUILD} ]; then
  rm -rf ${OSSL_BUILD}
fi

# Extract libssl source
curl -L https://www.openssl.org/source/${OSSL_BUILD}.tar.gz -o ${OSSL_BUILD}.tar.gz
tar zxvf ${OSSL_BUILD}.tar.gz

# Change to the source dir
cd ${OSSL_BUILD}

# Build libssl
KERNEL_BITS=64 ./config no-shared \
            --prefix=${SCRIPT_DIR}/${OSSL_DIR}
make depend
make all
make install

# Install the openssl into the scripts directory
echo "Installing ${OSSL_DIR}"

# Copy the static/dynamic lib into the project
OSSL_HEADER_FILE="${OSSL_INCLUDE}/openssl"
OSSL_STATIC_LIB_FILE="${OSSL_LIBS}/libssl.a"
CRPT_STATIC_LIB_FILE="${OSSL_LIBS}/libcrypto.a"

echo "Copying ${OSSL_HEADER_FILE} => ${PROJECT_INCLUDE}"
cp -r ${OSSL_HEADER_FILE} ${PROJECT_INCLUDE}

echo "Copying ${OSSL_STATIC_LIB_FILE} => ${PROJECT_LIBS}"
cp ${OSSL_STATIC_LIB_FILE} ${PROJECT_LIBS}

echo "Copying ${CRPT_STATIC_LIB_FILE} => ${PROJECT_LIBS}"
cp ${CRPT_STATIC_LIB_FILE} ${PROJECT_LIBS}

####
echo +++++++++++++++++++++++++
echo +++++ ${SSH2_BUILD} +++++
echo +++++++++++++++++++++++++
####

cd ${SCRIPT_DIR}

if [ -d ${SSH2_DIR} ]; then
  rm -rf ${SSH2_DIR}
fi

if [ -d ${SSH2_BUILD} ]; then
  rm -rf ${SSH2_BUILD}
fi

# Extract libssh2 source
curl -L https://www.libssh2.org/snapshots/${SSH2_BUILD}.tar.gz -o ${SSH2_BUILD}.tar.gz
tar zxvf ${SSH2_BUILD}.tar.gz

# Change to the source dir
cd ${SSH2_BUILD}

# Build libssh2
./configure --enable-shared=no \
            --with-libssl-prefix=${SCRIPT_DIR}/${OSSL_DIR} \
            --prefix=${SCRIPT_DIR}/${SSH2_DIR}
make
make install

# Install the ssh2 lib into the scripts directory
echo "Installing ${SSH2_DIR}"

# Copy the static/dynamic lib into the project
SSH2_STATIC_LIB_FILE="${SSH2_LIBS}/libssh2.a"

echo "Copying ${SSH2_STATIC_LIB_FILE} => ${PROJECT_LIBS}"
cp ${SSH2_STATIC_LIB_FILE} ${PROJECT_LIBS}

####
echo +++++++++++++++++++++++++
echo +++++ ${CURL_BUILD} +++++
echo +++++++++++++++++++++++++
####

export CPPFLAGS="-I${PROJECT_INCLUDE} -I${SSH2_INCLUDE} -I${OSSL_INCLUDE} -I${ZLIB_INCLUDE}"
export LDFLAGS="-L${PROJECT_LIBS} -L${SSH2_LIBS} -L${OSSL_LIBS} -L${ZLIB_LIBS}"

cd ${SCRIPT_DIR}

if [ -d ${CURL_BUILD} ]; then
   rm -rf ${CURL_BUILD}
fi

# Extract libcurl source
curl -L https://curl.haxx.se/snapshots/${CURL_BUILD}.tar.bz2 -o ${CURL_BUILD}.tar.bz2
tar jxvf ${CURL_BUILD}.tar.bz2

# Change to the source dir
cd ${CURL_BUILD}

# Build libcurl
export LIBS="-lssh2 -lssl -lz"
./configure --enable-static \
            --disable-shared \
            --disable-ldap \
            --with-libssh2
make

# Copy the static lib into the project
CURL_STATIC_LIB_FILE="lib/.libs/libcurl.a"
echo "Copying ${CURL_STATIC_LIB_FILE} => ${PROJECT_LIBS}"
cp ${CURL_STATIC_LIB_FILE} ${PROJECT_LIBS}

###
echo +++++++++++++++++++++++++
echo ++++++++ Cleanup ++++++++
echo +++++++++++++++++++++++++
###
cd ${SCRIPT_DIR}
echo "Removing directory ${ZLIB_DIR}"
rm -rf ${ZLIB_DIR}
echo "Removing directory ${ZLIB_BUILD}"
rm -rf ${ZLIB_BUILD}
echo "Removing directory ${OSSL_DIR}"
rm -rf ${OSSL_DIR}
echo "Removing directory ${OSSL_BUILD}"
rm -rf ${OSSL_BUILD}
echo "Removing directory ${SSH2_DIR}"
rm -rf ${SSH2_DIR}
echo "Removing directory ${SSH2_BUILD}"
rm -rf ${SSH2_BUILD}
echo "Removing directory ${CURL_BUILD}"
rm -rf ${CURL_BUILD}
