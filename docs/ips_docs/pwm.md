## Summary

| Name                              | Offset   |   Length | Description                                     |
|:----------------------------------|:---------|---------:|:------------------------------------------------|
| pwm.[`REGWEN`](#regwen)           | 0x0      |        4 | Register write enable for all control registers |
| pwm.[`CFG`](#cfg)                 | 0x4      |        4 | Configuration register                          |
| pwm.[`PWM_EN`](#pwm_en)           | 0x8      |        4 | Enable PWM operation for each channel           |
| pwm.[`INVERT`](#invert)           | 0xc      |        4 | Invert the PWM output for each channel          |
| pwm.[`PWM_PARAM`](#pwm_param)     | 0x10     |        4 | Basic PWM Channel Parameters                    |
| pwm.[`DUTY_CYCLE`](#duty_cycle)   | 0x14     |        4 | Controls the duty_cycle of each channel.        |
| pwm.[`BLINK_PARAM`](#blink_param) | 0x18     |        4 | Hardware controlled blink/heartbeat parameters. |

## REGWEN
Register write enable for all control registers
- Offset: `0x0`
- Reset default: `0x1`
- Reset mask: `0x1`

### Fields

```wavejson
{"reg": [{"name": "REGWEN", "bits": 1, "attr": ["rw0c"], "rotate": -90}, {"bits": 31}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name   | Description                                                                                                                                                                                                                         |
|:------:|:------:|:-------:|:-------|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|  31:1  |        |         |        | Reserved                                                                                                                                                                                                                            |
|   0    |  rw0c  |   0x1   | REGWEN | When true, all writable registers can be modified. When false, they become read-only. Defaults true, write zero to clear. This can be cleared after initial configuration at boot in order to lock in the listed register settings. |

## CFG
Configuration register
- Offset: `0x4`
- Reset default: `0x38008000`
- Reset mask: `0xffffffff`
- Register enable: [`REGWEN`](#regwen)

### Fields

```wavejson
{"reg": [{"name": "CLK_DIV", "bits": 27, "attr": ["rw"], "rotate": 0}, {"name": "DC_RESN", "bits": 4, "attr": ["rw"], "rotate": -90}, {"name": "CNTR_EN", "bits": 1, "attr": ["rw"], "rotate": -90}], "config": {"lanes": 1, "fontsize": 10, "vspace": 90}}
```

|  Bits  |  Type  |  Reset  | Name                     |
|:------:|:------:|:-------:|:-------------------------|
|   31   |   rw   |   0x0   | [CNTR_EN](#cfg--cntr_en) |
| 30:27  |   rw   |   0x7   | [DC_RESN](#cfg--dc_resn) |
|  26:0  |   rw   | 0x8000  | [CLK_DIV](#cfg--clk_div) |

### CFG . CNTR_EN
Assert this bit to enable the PWM phase counter.
   Clearing this bit disables and resets the phase counter.

### CFG . DC_RESN
Phase Resolution (logarithmic). All duty-cycle and phase
   shift registers represent fractional PWM cycles, expressed in
   units of 2^16 PWM cycles. Each PWM cycle  is divided
   into 2^(DC_RESN+1) time slices, and thus only the (DC_RESN+1)
   most significant bits of each phase or duty cycle register
   are relevant.

### CFG . CLK_DIV
Sets the period of each PWM beat to be (CLK_DIV+1)
   input clock periods.  Since PWM pulses are generated once
   every 2^(DC_RESN+1) beats, the period between output
   pulses is 2^(DC_RESN+1)*(CLK_DIV+1) times longer than the
   input clock period.

## PWM_EN
Enable PWM operation for each channel
- Offset: `0x8`
- Reset default: `0x0`
- Reset mask: `0x1`
- Register enable: [`REGWEN`](#regwen)

### Fields

```wavejson
{"reg": [{"name": "EN_0", "bits": 1, "attr": ["rw"], "rotate": -90}, {"bits": 31}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name   | Description                                                            |
|:------:|:------:|:-------:|:-------|:-----------------------------------------------------------------------|
|  31:1  |        |         |        | Reserved                                                               |
|   0    |   rw   |   0x0   | EN_0   | Write 1 to this bit to enable PWM pulses on the corresponding channel. |

## INVERT
Invert the PWM output for each channel
- Offset: `0xc`
- Reset default: `0x0`
- Reset mask: `0x1`
- Register enable: [`REGWEN`](#regwen)

### Fields

```wavejson
{"reg": [{"name": "INVERT_0", "bits": 1, "attr": ["rw"], "rotate": -90}, {"bits": 31}], "config": {"lanes": 1, "fontsize": 10, "vspace": 100}}
```

|  Bits  |  Type  |  Reset  | Name     | Description                                                                                                |
|:------:|:------:|:-------:|:---------|:-----------------------------------------------------------------------------------------------------------|
|  31:1  |        |         |          | Reserved                                                                                                   |
|   0    |   rw   |   0x0   | INVERT_0 | Write 1 to this bit to invert the output for each channel, so that the corresponding output is active-low. |

## PWM_PARAM
Basic PWM Channel Parameters
- Reset default: `0x0`
- Reset mask: `0xc000ffff`
- Register enable: [`REGWEN`](#regwen)

### Instances

| Name      | Offset   |
|:----------|:---------|
| PWM_PARAM | 0x10     |


### Fields

```wavejson
{"reg": [{"name": "PHASE_DELAY", "bits": 16, "attr": ["rw"], "rotate": 0}, {"bits": 14}, {"name": "HTBT_EN", "bits": 1, "attr": ["rw"], "rotate": -90}, {"name": "BLINK_EN", "bits": 1, "attr": ["rw"], "rotate": -90}], "config": {"lanes": 1, "fontsize": 10, "vspace": 100}}
```

|  Bits  |  Type  |  Reset  | Name                                   |
|:------:|:------:|:-------:|:---------------------------------------|
|   31   |   rw   |   0x0   | [BLINK_EN](#pwm_param--blink_en)       |
|   30   |   rw   |   0x0   | [HTBT_EN](#pwm_param--htbt_en)         |
| 29:16  |        |         | Reserved                               |
|  15:0  |   rw   |   0x0   | [PHASE_DELAY](#pwm_param--phase_delay) |

### PWM_PARAM . BLINK_EN
Enables blink (or heartbeat).  If cleared, the output duty
   cycle will remain constant at DUTY_CYCLE.A. Enabling this
   bit  causes the PWM duty cycle to fluctuate between
   DUTY_CYCLE.A and DUTY_CYCLE.B

### PWM_PARAM . HTBT_EN
Modulates blink behavior to create a heartbeat effect. When
   HTBT_EN is set, the duty cycle increases (or decreases)
   linearly from DUTY_CYCLE.A to DUTY_CYCLE.B and back, in
   steps of (BLINK_PARAM.Y+1), with an increment (decrement)
   once every (BLINK_PARAM.X+1) PWM cycles. When HTBT_EN is
   cleared, the standard blink behavior applies, meaning that
   the output duty cycle alternates between DUTY_CYCLE.A for
   (BLINK_PARAM.X+1) pulses and DUTY_CYCLE.B for
   (BLINK_PARAM.Y+1) pulses.

### PWM_PARAM . PHASE_DELAY
Phase delay of the PWM rising edge, in units of 2^(-16) PWM
   cycles

## DUTY_CYCLE
Controls the duty_cycle of each channel.
- Reset default: `0x7fff7fff`
- Reset mask: `0xffffffff`
- Register enable: [`REGWEN`](#regwen)

### Instances

| Name       | Offset   |
|:-----------|:---------|
| DUTY_CYCLE | 0x14     |


### Fields

```wavejson
{"reg": [{"name": "A", "bits": 16, "attr": ["rw"], "rotate": 0}, {"name": "B", "bits": 16, "attr": ["rw"], "rotate": 0}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name                |
|:------:|:------:|:-------:|:--------------------|
| 31:16  |   rw   | 0x7fff  | [B](#duty_cycle--b) |
|  15:0  |   rw   | 0x7fff  | [A](#duty_cycle--a) |

### DUTY_CYCLE . B
The target duty cycle for PWM output, in units
   of 2^(-16)ths of a pulse cycle. The actual precision is
   however limited to the (DC_RESN+1) most significant bits.
   This setting only applies when blinking, and determines
   the target duty cycle.

### DUTY_CYCLE . A
The initial duty cycle for PWM output, in units
   of 2^(-16)ths of a pulse cycle. The actual precision is
   however limited to the (DC_RESN+1) most significant bits.
   This setting applies continuously when not blinking
   and determines the initial duty cycle when blinking.

## BLINK_PARAM
Hardware controlled blink/heartbeat parameters.
- Reset default: `0x0`
- Reset mask: `0xffffffff`
- Register enable: [`REGWEN`](#regwen)

### Instances

| Name        | Offset   |
|:------------|:---------|
| BLINK_PARAM | 0x18     |


### Fields

```wavejson
{"reg": [{"name": "X", "bits": 16, "attr": ["rw"], "rotate": 0}, {"name": "Y", "bits": 16, "attr": ["rw"], "rotate": 0}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name                 |
|:------:|:------:|:-------:|:---------------------|
| 31:16  |   rw   |   0x0   | [Y](#blink_param--y) |
|  15:0  |   rw   |   0x0   | [X](#blink_param--x) |

### BLINK_PARAM . Y
This blink-rate timing parameter has two different
   interpretations depending on whether or not the heartbeat
   feature is enabled. If heartbeat is disabled, a blinking
   PWM will pulse at duty cycle B for (Y+1) pulse cycles
   before returning to duty cycle A. If heartbeat is enabled
   the duty cycle will increase (or decrease) by (Y+1) units
   every time it is incremented (or decremented)

### BLINK_PARAM . X
This blink-rate timing parameter has two different
   interpretations depending on whether or not the heartbeat
   feature is enabled. If heartbeat is disabled, a blinking
   PWM will pulse at duty cycle A for (X+1) pulses before
   switching to duty cycle B. If heartbeat is enabled
   the duty-cycle will start at the duty cycle A, but
   will be incremented (or decremented) every (X+1) cycles.
   In heartbeat mode is enabled, the size of each step is
   controlled by BLINK_PARAM.Y.

