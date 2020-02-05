#!/usr/bin/env sh

# Copyright 2019 The Imaging Source Europe GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This script attempts to ease the installation of dependencies
# It does this by checking the distribution and installing the packages
# according to the dependency list described in the correlating file.


# project base folder
TISCAMERA_DIR=



# Distribution in use
DISTRIBUTION="DEBIAN"
ASSUME_YES="-y"
export DEBIAN_FRONTEND="noninteractive"

# possible values currently are:
# DEBIAN
# RHEL
# ARCH


# Retrieve the base dir of the tiscamera project
#
get_dir () {
    # Absolute path to this script, e.g. /home/user/bin/foo.sh
    SCRIPT=$(readlink -f "$0")
    # Absolute path this script is in, thus /home/user/bin
    SCRIPTPATH=$(dirname "$SCRIPT")
    # echo ${SCRIPTPATH%/*}
    TISCAMERA_DIR="${SCRIPTPATH%/*}"
}


#
# Check package manager to determine used distribution
# Sets global DISTRIBUTION accordingly
#
get_distribution () {

    if [ -x "$(command -v dpkg)" ]; then
        DISTRIBUTION="DEBIAN"
    else
        echo "Unable to determine distribution."
        DISTRIBUTION=
    fi
}


# read file given as $1
# remove comments
# convert it to a single line
# remove version information and commata
# echo a string as return value
read_file () {

    if [ -z "$1" ]; then
        echo "No file name given from which to read dependencies!"
        exit 1
    fi

    echo $(grep -vE "^\\s*#" $1  | tr "\n" " " | sed -e 's/([^()]*)//g; s/,//g')
}

#
# DEBIAN SECTION
#

install_dependencies_debian_compilation () {
 DEBIAN_FRONTEND="noninteractive" sudo apt-get install -y git g++ cmake pkg-config uuid-dev \
    libudev-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
    libglib2.0-dev libgirepository1.0-dev libusb-1.0-0-dev \
    libzip-dev python3-setuptools libxml2-dev \
    autoconf intltool gtk-doc-tools libpcap-dev
}


install_dependencies_debian_runtime () {
DEBIAN_FRONTEND="noninteractive" sudo apt-get install -y libgstreamer1.0-0 gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly libxml2 libzip4 libglib2.0-0 libgirepository-1.0-1 libudev1 libusb-1.0-0 libuuid1 libxml2 libpcap0.8 python3-pyqt5 python3-gi
}

# General install/remove routines
#

install_compile_dependencies () {
    case "$DISTRIBUTION" in
        DEBIAN)
            install_dependencies_debian_compilation || echo "Failed to install compilation dependencies"
            ;;
        *)
            printf "Distribution '%s' is not supported.\n" $DISTRIBUTION
            exit 1
    esac
}


install_runtime_dependencies () {
    case "$DISTRIBUTION" in
        DEBIAN)
            install_dependencies_debian_runtime || echo "Failed to install runtime dependencies"
            ;;
        *)
            printf "Distribution '%s' is not supported.\n" $DISTRIBUTION
            exit 1
    esac
}


usage () {
    printf "%s\n" "$0"
    printf "install dependencies for the tiscamera project\n"
    printf "options:\n"
    printf "\t--compilation \t Install compilation dependencies\n"
    printf "\t--runtime \t Install runtime dependencies\n"
    printf "\t--help \t\t Print this message\n"
}

#
# start of actual script
#

install_compilation=0
install_runtime=0

if [ $# -eq 0 ]; then
    usage
    exit 1
fi

get_dir

get_distribution


while [ "$1" != "" ]; do
    PARAM=$(echo "$1" | awk -F= '{print $1}')
    # VALUE=$(echo $1 | awk -F= '{print $2}')
    case $PARAM in
        -h | --help)
            usage
            exit
            ;;
        --compilation)
            install_compilation=1
            ;;
        --runtime)
            install_runtime=1
            ;;
        --yes)
            ASSUME_YES="-y"
            ;;
        *)
            echo "ERROR: unknown parameter \"$PARAM\""
            usage
            exit 1
            ;;
    esac
    shift
done

if [ $install_compilation -eq 0 ] && [ $install_runtime -eq 0 ]; then
    echo "Please specify if compilation and/or runtime dependencies should be installed."
    exit 1
fi


if [ $install_compilation -eq 1 ]; then
    install_compile_dependencies
fi

if [ $install_runtime -eq 1 ]; then
    install_runtime_dependencies
fi
