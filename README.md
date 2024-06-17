# Tang Nano 9K

> :bell: continued in https://github.com/calint/tang-nano-9k--riscv--cache-psram

step-wise development towards a RISC-V rv32i implementation supporting cache of PSRAM

## todo
```
[x] step 9: read from flash, write to cache
[x] step 10: implement ram interface
[x]   writing to UART address triggers cache fetch line
      => cache.enable added
[ ] fix truncation warnings
[ ] update test Cache (write_enable && line_dirty) to (line_dirty)
[x] update RAMIO issue lh from {24{}} to {16{}} 
[x] step 11: adapt riscv core (multi-cycle simplest way forward with ad-hoc pipe-lining)
[ ] step 12: pipe-lined core

```