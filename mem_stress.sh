#!/bin/bash


MEM_TOTAL=$(awk '/MemTotal/ {print int($2/1024)}' /proc/meminfo)

MEM_USE=$((MEM_TOTAL*80/100))


echo "Memory stress allocate ${MEM_USE} MB"


stress-ng \
--vm 2 \
--vm-bytes ${MEM_USE}M \
--vm-keep \
--page-in \
--timeout 999999
