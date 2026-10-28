#!/bin/bash


DIR=/root/rk3588_stress
LOG_DIR=$DIR/logs


mkdir -p $LOG_DIR


LOG=$LOG_DIR/stress_$(date +%Y%m%d_%H%M%S).log


echo "========================================" > $LOG
echo "RK3588 Stress Test" >> $LOG
echo "START: $(date)" >> $LOG
echo "========================================" >> $LOG



while true
do


TIME=$(date "+%F %T")



################################
# CPU
################################

CPU=$(top -bn1 | grep "Cpu(s)" | \
awk '{print 100-$8}')

CPU=$(printf "%.1f" $CPU)



################################
# MEMORY
################################

MEM=$(free -m | awk 'NR==2{
printf "%.1f", $3/$2*100
}')



################################
# GPU
################################

GPU_LOAD=""
GPU_FREQ=""



GPU_NODE=/sys/class/devfreq/fb000000.gpu


if [ -d $GPU_NODE ]
then

GPU_LOAD=$(cat $GPU_NODE/load 2>/dev/null | cut -d@ -f1)
GPU_FREQ=$(cat $GPU_NODE/cur_freq 2>/dev/null)

GPU_FREQ=$((GPU_FREQ/1000000))

fi



################################
# NPU
################################


NPU_LOAD=""

NPU_FREQ=""


if [ -f /sys/kernel/debug/rknpu/load ]
then

NPU_LOAD=$(cat /sys/kernel/debug/rknpu/load | \
sed \
-e 's/NPU load://' \
-e 's/Core/C/g' \
-e 's/,//g' \
-e 's/  */ /g')

fi



if [ -d /sys/class/devfreq/fdab0000.npu ]
then

NPU_FREQ=$(cat \
/sys/class/devfreq/fdab0000.npu/cur_freq)

NPU_FREQ=$((NPU_FREQ/1000000))

fi




################################
# TEMPERATURE
################################


SOC=""
BIG0=""
BIG1=""
CENTER=""
GPU_TEMP=""
NPU_TEMP=""


for zone in /sys/class/thermal/thermal_zone*
do


TYPE=$(cat $zone/type 2>/dev/null)

TEMP=$(cat $zone/temp 2>/dev/null)


if [ -z "$TEMP" ]
then
continue
fi


TEMP=$((TEMP/1000))


case $TYPE in


soc-thermal)

SOC=${TEMP}C
;;

bigcore0-thermal)

BIG0=${TEMP}C
;;

bigcore1-thermal)

BIG1=${TEMP}C
;;

center-thermal)

CENTER=${TEMP}C
;;

gpu-thermal)

GPU_TEMP=${TEMP}C
;;

npu-thermal)

NPU_TEMP=${TEMP}C
;;

esac


done
TEMP_INFO="soc:$SOC big0:$BIG0 big1:$BIG1 center:$CENTER gpu:$GPU_TEMP npu:$NPU_TEMP"

################################
# OUTPUT
################################
INFO="$TIME | CPU:${CPU}% | MEM:${MEM}% | GPU:${GPU_LOAD}@${GPU_FREQ}MHz | NPU:${NPU_LOAD}@${NPU_FREQ}MHz | TEMP:${TEMP_INFO}"
echo "$INFO"
echo "$INFO" >> $LOG
sleep 5
done
