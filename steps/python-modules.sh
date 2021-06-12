#!/bin/bash

cd /
python3.9 -m crossenv /dst/usr/bin/python3 venv
. venv/bin/activate

pip install cobs pyserial stm32loader
# installed to venv/cross/lib/python3.9/site-packages

mkdir -p /dst_mod/usr/lib/python3.9/site-packages
cp -r /venv/cross/lib/python3.9/site-packages/{cobs,serial,stm32loader,progress} /dst_mod/usr/lib/python3.9/site-packages
