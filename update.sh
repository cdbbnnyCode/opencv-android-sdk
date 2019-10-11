#!/bin/bash
# update.sh -- OpenCV library updater
# Runs build_sdk.py in an OpenCV git clone located like so:
# ~
# |- opencv-android-sdk/ <-- You are here
# |- opencv/             <-- OpenCV is here


here=$(pwd)
pushd . >/dev/null

function onexit()
{
  popd >/dev/null
  if [ -z "$1" ]; then
    exit 1
  else
    exit $1
  fi
}

function usage()
{
  echo "Usage:"
  echo "$0 [option]"
  echo "Options:"
  echo "    -h|--help    Show this help and exit"
  echo "    --no-build   Don't recompile; only copy the files"
  onexit $1
}

function print_version()
{
  vers=($(grep '#define CV_VERSION_' ../../modules/core/include/opencv2/core/version.hpp | awk -F '_' '{print $3}' | awk '{print $2}' | tr -d '"'))
  echo ${vers[0]}.${vers[1]}.${vers[2]}${vers[3]}
}

trap onexit 2

cd ../opencv/platforms/android

for opt in $@; do
  case "$opt" in
    --no-build)
      no_build=1
      ;;
    -h|--help)
      usage 0
      ;;
    *)
      echo "Unknown argument: $opt"
      echo
      usage 1
      ;;
  esac
done

mkdir -p build
echo "Updating to OpenCV version $(print_version)"

if [ ! -e ../../patched.txt ]; then
  echo "Patching OpenCV"
  cd ../../
  git apply $here/opencv.patch
  cd platforms/android
fi

if [ -z "$no_build" ]; then
  echo "Compiling OpenCV for Android..."
  python build_sdk.py --build_doc --extra_modules_path ~/Documents/opencv_contrib/modules/ build/
fi

cp build/OpenCV-android-sdk/* $here
rm -r sdk
cp -rv build/OpenCV-android-sdk/sdk $here

onexit
