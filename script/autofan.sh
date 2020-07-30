#!/bin/bash
#
# This is a script to run the clevo utility in auto fan mode passing through the GPU temperature via nvidia-smi.
# Please make sure that nvidia-smi is installed, and that its output format matches the one expected by clevo indicator.
# Use at your own risk!
#
if [ `ps aux | grep -v grep | grep clevo-indicator | wc -l` != "0" ]; then
    echo "Already running";
    exit 1;
fi
/opt/bin/nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader -l 3 | /home/qon/scripts/clevo-indicator auto
