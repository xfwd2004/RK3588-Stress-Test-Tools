#!/bin/bash


LOG=/root/rk3588_stress/temp.log


echo "time,soc,cpu_big,cpu_little,gpu,npu" > $LOG


while true
do

TIME=$(date "+%H:%M:%S")


SOC=""
CPU_BIG=""
CPU_LITTLE=""
GPU=""
NPU=""


for zone in /sys/class/thermal/thermal_zone*
do

    TYPE=$(cat $zone/type)
    TEMP=$(cat $zone/temp 2>/dev/null)

    TEMP=$(($TEMP/1000))


    case $TYPE in

        *soc*)
            SOC=$TEMP
        ;;

        *center*)
            SOC=$TEMP
        ;;

        *big*)
            CPU_BIG=$TEMP
        ;;


        *little*)
            CPU_LITTLE=$TEMP
        ;;


        *gpu*)
            GPU=$TEMP
        ;;


        *npu*)
            NPU=$TEMP
        ;;

    esac

done



echo "$TIME,$SOC,$CPU_BIG,$CPU_LITTLE,$GPU,$NPU" \
>> $LOG



echo "
==============================
TIME : $TIME

SOC       : ${SOC} C
CPU BIG   : ${CPU_BIG} C
CPU LITTLE: ${CPU_LITTLE} C
GPU       : ${GPU} C
NPU       : ${NPU} C

==============================
"


sleep 2

done
