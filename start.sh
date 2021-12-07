#!/usr/bin/env

BOOT_SECTOR_BIN=boot_sect.bin
WORKING_DIR=operatingSystemDev

# compile my boot_sector.asm to a binary file
nasm "${HOME}/${WORKING_DIR}/boot/boot_sect.asm" -f bin -o "${HOME}/${WORKING_DIR}/boot/boot_sect.bin"

# start simulator
bochs