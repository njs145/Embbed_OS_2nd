#!/bin/bash

#1. Check if gcc-arm-none-eabi is installed
if dpkg -l | grep -q gcc-arm-none-eabi; 
then
    echo "gcc-arm-none-eabi is installed."
else
    echo "gcc-arm-none-eabi is not installed."

    sudo apt-get install gcc-arm-none-eabi
    sudo apt-get update

    arm-none-eabi-gcc -v
fi

#2. Check if qemu-system-arm is installed
if dpkg -l | grep -q qemu-system-arm;
then
    echo "qemu-system-arm is installed."
else
    echo "qemu-system-arm is not installed."
    sudo apt install qemu-system-arm
    qemu-system-arm --version
    qemu-system-arm -M ?
fi

#3. Check if gdb-multiarch is installed
if dpkg -l | grep -q multiarch;
then
    echo "multiarch is installed."
else
    echo "multiarch is not installed."
    sudo apt install qemu-system-arm
fi