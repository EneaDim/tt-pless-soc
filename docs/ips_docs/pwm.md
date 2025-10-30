## Summary

| Name                          | Offset   |   Length | Description                           |
|:------------------------------|:---------|---------:|:--------------------------------------|
| pwm.[`CFG`](#cfg)             | 0x0      |        4 | Configuration register                |
| pwm.[`PWM_EN`](#pwm_en)       | 0x4      |        4 | Enable PWM operation for each channel |
| pwm.[`PWM_PARAM`](#pwm_param) | 0x8      |        4 | Basic PWM Channel Parameters          |

## CFG
Configuration register
- Offset: `0x0`
- Reset default: `0x38008000`
- Reset mask: `0xffffffff`

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
- Offset: `0x4`
- Reset default: `0x0`
- Reset mask: `0x1`

### Fields

```wavejson
{"reg": [{"name": "EN_0", "bits": 1, "attr": ["rw"], "rotate": -90}, {"bits": 31}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name   | Description                                                            |
|:------:|:------:|:-------:|:-------|:-----------------------------------------------------------------------|
|  31:1  |        |         |        | Reserved                                                               |
|   0    |   rw   |   0x0   | EN_0   | Write 1 to this bit to enable PWM pulses on the corresponding channel. |

## PWM_PARAM
Basic PWM Channel Parameters
- Reset default: `0x7fff0000`
- Reset mask: `0xffffffff`

### Instances

| Name      | Offset   |
|:----------|:---------|
| PWM_PARAM | 0x8      |


### Fields

```wavejson
{"reg": [{"name": "PHASE_DELAY", "bits": 16, "attr": ["rw"], "rotate": 0}, {"name": "DUTY_CYCLE", "bits": 16, "attr": ["rw"], "rotate": 0}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name                                   |
|:------:|:------:|:-------:|:---------------------------------------|
| 31:16  |   rw   | 0x7fff  | [DUTY_CYCLE](#pwm_param--duty_cycle)   |
|  15:0  |   rw   |   0x0   | [PHASE_DELAY](#pwm_param--phase_delay) |

### PWM_PARAM . DUTY_CYCLE
The target duty cycle for PWM output, in units
   of 2^(-16)ths of a pulse cycle. The actual precision is
   however limited to the (DC_RESN+1) most significant bits.
   This setting only applies when blinking, and determines
   the target duty cycle.

### PWM_PARAM . PHASE_DELAY
Phase delay of the PWM rising edge, in units of 2^(-16) PWM
   cycles

