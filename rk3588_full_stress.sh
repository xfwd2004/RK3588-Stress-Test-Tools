#!/bin/bash


DIR=/root/rk3588_stress


echo "=============================="
echo "RK3588 FULL STRESS TEST"
echo "=============================="


# 温度监控

$DIR/monitor_temp.sh &

TEMP_PID=$!


sleep 3


echo "CPU TEST"

stress-ng \
--cpu 8 \
--cpu-method matrixprod \
--timeout 7200s \
--metrics-brief &


CPU_PID=$!



echo "MEM TEST"

stress-ng \
--vm 4 \
--vm-bytes 70% \
--timeout 7200s &


MEM_PID=$!



echo "NPU TEST"


/root/rk3588_stress/npu_test.sh &


NPU_PID=$!



echo "
TEST RUNNING

CPU PID=$CPU_PID
MEM PID=$MEM_PID
NPU PID=$NPU_PID

Press CTRL+C stop
"



wait
