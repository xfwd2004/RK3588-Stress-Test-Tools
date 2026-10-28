#!/bin/bash


echo "GPU stress start"


DIR=/root/rk3588_stress


glmark2-es2 \
--off-screen \
--run-forever \
--benchmark refract \
--benchmark terrain \
--benchmark build \
--benchmark shadow \
--benchmark texture \
>/tmp/gpu1.log 2>&1 &


PID1=$!



glmark2-es2 \
--off-screen \
--run-forever \
--benchmark refract \
--benchmark terrain \
--benchmark build \
--benchmark shadow \
--benchmark texture \
>/tmp/gpu2.log 2>&1 &


PID2=$!


echo $PID1 > $DIR/gpu_child.pid
echo $PID2 >> $DIR/gpu_child.pid


wait
