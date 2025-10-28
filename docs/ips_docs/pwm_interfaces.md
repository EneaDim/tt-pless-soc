Referring to the [Comportable guideline for peripheral device functionality](https://opentitan.org/book/doc/contributing/hw/comportability), the module **`pwm`** has the following hardware interfaces defined
- Primary Clock: **`clk_i`**
- Other Clocks: *none*
- Bus Device Interfaces (TL-UL): **`tl`**
- Bus Host Interfaces (TL-UL): *none*
- Interrupts: *none*
- Security Alerts: *none*

## Peripheral Pins for Chip IO

| Pin name   | Direction   | Description                                                                                                                                                                     |
|:-----------|:------------|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| pwm        | output      | Pulse output.  Note that though this output is always enabled, there is a formal set of enable pins (pwm_en_o) which are required for top-level integration of comportable IPs. |

## [Inter-Module Signals](https://opentitan.org/book/doc/contributing/hw/comportability/index.html#inter-signal-handling)

| Port Name   | Package::Struct   | Type    | Act   |   Width | Description   |
|:------------|:------------------|:--------|:------|--------:|:--------------|
| tl          | tlul_pkg::tl      | req_rsp | rsp   |       1 |               |

## Security Countermeasures

| Countermeasure ID   | Description                      |
|:--------------------|:---------------------------------|
| PWM.BUS.INTEGRITY   | End-to-end bus integrity scheme. |

