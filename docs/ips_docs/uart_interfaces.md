Referring to the [Comportable guideline for peripheral device functionality](https://opentitan.org/book/doc/contributing/hw/comportability), the module **`uart`** has the following hardware interfaces defined
- Primary Clock: **`clk_i`**
- Other Clocks: *none*
- Bus Device Interfaces (TL-UL): **`tl`**
- Bus Host Interfaces (TL-UL): *none*
- Interrupts: *none*
- Security Alerts: *none*
- Security Countermeasures: *none*

## Peripheral Pins for Chip IO

| Pin name   | Direction   | Description         |
|:-----------|:------------|:--------------------|
| rx         | input       | Serial receive bit  |
| tx         | output      | Serial transmit bit |

## [Inter-Module Signals](https://opentitan.org/book/doc/contributing/hw/comportability/index.html#inter-signal-handling)

| Port Name   | Package::Struct   | Type    | Act   |   Width | Description   |
|:------------|:------------------|:--------|:------|--------:|:--------------|
| tl          | tlul_pkg::tl      | req_rsp | rsp   |       1 |               |

