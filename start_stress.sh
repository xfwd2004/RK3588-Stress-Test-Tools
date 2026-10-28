#!/bin/bash


DIR=/root/rk3588_stress


echo "============================"
echo "RK3588 Stress Start"
echo "============================"


#
# Monitor
#
$DIR/monitor.sh &
echo $! > monitor.pid



#
# CPU Stress
#
$DIR/cpu_stress.sh &
echo $! > cpu.pid



#
# Memory Stress
#
$DIR/mem_stress.sh &
echo $! > mem.pid



#
# GPU Stress
#
$DIR/gpu_stress.sh &
echo $! > gpu.pid



#
# NPU Stress
#
/root/test/rknn_venv/bin/python3 \
$DIR/npu_stress.py \
>/tmp/npu_stress.log 2>&1 &

echo $! > npu.pid



echo ""
echo "Stress running"
echo ""
echo "Monitor log:"
echo "tail -f logs/*.log"
echo ""
echo "NPU log:"
echo "cat /tmp/npu_stress.log"
echo ""
echo "Stop:"
echo "./stop_stress.sh"
