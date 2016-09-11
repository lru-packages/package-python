#!/usr/bin/env bash

# The script to be run after the python-devel package
echo "/usr/local/lib" >> /etc/ld.so.conf
ldconfig
