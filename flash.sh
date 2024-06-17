#!/bin/bash
set -e

cd $(dirname "$0")

# write bitstream to memory only
openFPGALoader -b tangnano9k impl/pnr/riscv.fs

# write bitstream to flash
# openFPGALoader -b tangnano9k -f impl/pnr/riscv.fs

# write user data
# openFPGALoader -b tangnano9k --verify --external-flash os/os.bin
