#!/bin/bash

export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true

cat > preseed.txt <<EOF
tzdata tzdata/Areas select Europe
tzdata tzdata/Zones/Europe select Berlin
locales locales/locales_to_be_generated    multiselect en_US.UTF-8 UTF-8
locales locales/default_environment_locale      select en_US.UTF-8
EOF
debconf-set-selections preseed.txt

apt update -y
apt install -y software-properties-common
add-apt-repository -y ppa:deadsnakes/ppa
apt update -y
apt install -y wget python3.9 python3-pip python3.9-distutils python3.9-distutils python3.9-venv

python3.9 -m pip install crossenv

# create final build directory
mkdir /dst
