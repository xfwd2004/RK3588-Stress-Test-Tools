#!/bin/bash


DIR=/root/rk3588_stress


echo "Stopping RK3588 Stress..."



# 主脚本PID

for f in \
cpu.pid \
mem.pid \
gpu.pid \
npu.pid \
monitor.pid

do

if [ -f $DIR/$f ]
then

PID=$(cat $DIR/$f)

kill -9 $PID 2>/dev/null

fi

done



# GPU子进程

if [ -f $DIR/gpu_child.pid ]
then

while read pid
do
kill -9 $pid 2>/dev/null
done < $DIR/gpu_child.pid

fi



# 清理残留压力程序

pkill -9 stress-ng-cpu
pkill -9 stress-ng-vm
pkill -9 glmark2-es2



echo ""
echo "Remaining stress process:"


ps -ef | grep -E \
"stress-ng|glmark2|cpu_stress|mem_stress|npu_stress" \
| grep -v grep



echo "" echo "Stress stopped"
