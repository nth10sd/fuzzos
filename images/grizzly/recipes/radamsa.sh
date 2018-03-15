#!/bin/bash -ex

# Build radamsa
cd /tmp
git clone -v --depth 1 https://github.com/aoh/radamsa.git
( cd radamsa
  make
  make install
)
rm -rf radamsa
