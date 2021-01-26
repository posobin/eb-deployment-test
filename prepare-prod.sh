#!/bin/sh

set -e

# To install python 3.8: https://techviewleo.com/how-to-install-python-on-amazon-linux/
# yum install -y amazon-linux-extras
# amazon-linux-extras enable python3.8
# yum install -y python3.8

pip3.7 install -r requirements.txt
