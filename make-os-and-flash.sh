#!/bin/bash

cd os/ && 
./make.sh && 
cd .. && 
openFPGALoader -b tangnano9k --external-flash os/os.bin &&
openFPGALoader -b tangnano9k -f impl/pnr/tang-nano-9k--step-11.fs
