#!/bin/bash


source /root/test/rknn_venv/bin/activate


cd /root/rk3588_stress


python3 npu_stress.py \
>/tmp/npu_stress.log 2>&1
