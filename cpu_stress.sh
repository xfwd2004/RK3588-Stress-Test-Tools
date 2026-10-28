#!/bin/bash


echo "CPU 8core 80% stress"


stress-ng \
--cpu 8 \
--cpu-load 80 \
--cpu-method matrixprod
