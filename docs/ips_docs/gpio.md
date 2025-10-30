## Summary

| Name                                                 | Offset   |   Length | Description                                           |
|:-----------------------------------------------------|:---------|---------:|:------------------------------------------------------|
| gpio.[`INTR_STATE`](#intr_state)                     | 0x0      |        4 | Interrupt State Register                              |
| gpio.[`INTR_ENABLE`](#intr_enable)                   | 0x4      |        4 | Interrupt Enable Register                             |
| gpio.[`INTR_TEST`](#intr_test)                       | 0x8      |        4 | Interrupt Test Register                               |
| gpio.[`DATA_IN`](#data_in)                           | 0xc      |        4 | GPIO Input data read value                            |
| gpio.[`DIRECT`](#direct)                             | 0x10     |        4 | GPIO direct output data write value and Output Enable |
| gpio.[`INTR_CTRL`](#intr_ctrl)                       | 0x14     |        4 | Combined GPIO interrupt control enables.              |
| gpio.[`CTRL_EN_INPUT_FILTER`](#ctrl_en_input_filter) | 0x18     |        4 | filter enable for GPIO input bits.                    |

## INTR_STATE
Interrupt State Register
- Offset: `0x0`
- Reset default: `0x0`
- Reset mask: `0x3`

### Fields

```wavejson
{"reg": [{"name": "gpio", "bits": 2, "attr": ["rw1c"], "rotate": -90}, {"bits": 30}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name   | Description                                                 |
|:------:|:------:|:-------:|:-------|:------------------------------------------------------------|
|  31:2  |        |         |        | Reserved                                                    |
|  1:0   |  rw1c  |   0x0   | gpio   | raised if any of GPIO pin detects configured interrupt mode |

## INTR_ENABLE
Interrupt Enable Register
- Offset: `0x4`
- Reset default: `0x0`
- Reset mask: `0x3`

### Fields

```wavejson
{"reg": [{"name": "gpio", "bits": 2, "attr": ["rw"], "rotate": -90}, {"bits": 30}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name   | Description                                                                         |
|:------:|:------:|:-------:|:-------|:------------------------------------------------------------------------------------|
|  31:2  |        |         |        | Reserved                                                                            |
|  1:0   |   rw   |   0x0   | gpio   | Enable interrupt when corresponding bit in [`INTR_STATE.gpio`](#intr_state) is set. |

## INTR_TEST
Interrupt Test Register
- Offset: `0x8`
- Reset default: `0x0`
- Reset mask: `0x3`

### Fields

```wavejson
{"reg": [{"name": "gpio", "bits": 2, "attr": ["wo"], "rotate": -90}, {"bits": 30}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name   | Description                                                                  |
|:------:|:------:|:-------:|:-------|:-----------------------------------------------------------------------------|
|  31:2  |        |         |        | Reserved                                                                     |
|  1:0   |   wo   |   0x0   | gpio   | Write 1 to force corresponding bit in [`INTR_STATE.gpio`](#intr_state) to 1. |

## DATA_IN
GPIO Input data read value
- Offset: `0xc`
- Reset default: `0x0`
- Reset mask: `0x3`

### Fields

```wavejson
{"reg": [{"name": "DATA_IN", "bits": 2, "attr": ["ro"], "rotate": -90}, {"bits": 30}], "config": {"lanes": 1, "fontsize": 10, "vspace": 90}}
```

|  Bits  |  Type  |  Reset  | Name    | Description   |
|:------:|:------:|:-------:|:--------|:--------------|
|  31:2  |        |         |         | Reserved      |
|  1:0   |   ro   |    x    | DATA_IN |               |

## DIRECT
GPIO direct output data write value and Output Enable
- Offset: `0x10`
- Reset default: `0x0`
- Reset mask: `0xf`

### Fields

```wavejson
{"reg": [{"name": "GPIO_O", "bits": 2, "attr": ["rw"], "rotate": -90}, {"name": "GPIO_OE", "bits": 2, "attr": ["rw"], "rotate": -90}, {"bits": 28}], "config": {"lanes": 1, "fontsize": 10, "vspace": 90}}
```

|  Bits  |  Type  |  Reset  | Name    | Description        |
|:------:|:------:|:-------:|:--------|:-------------------|
|  31:4  |        |         |         | Reserved           |
|  3:2   |   rw   |    x    | GPIO_OE | GPIO output enable |
|  1:0   |   rw   |    x    | GPIO_O  | GPIO output value  |

## INTR_CTRL
Combined GPIO interrupt control enables.
   If [`INTR_ENABLE`](#intr_enable)[i] is true, setting:
     - [`EN_RISING`](#en_rising)[i]   enables rising-edge interrupt detection on GPIO[i].
     - [`EN_FALLING`](#en_falling)[i]  enables falling-edge interrupt detection on GPIO[i].
     - [`EN_LVLHIGH`](#en_lvlhigh)[i]  enables level-high interrupt detection on GPIO[i].
     - [`EN_LVLLOW`](#en_lvllow)[i]   enables level-low interrupt detection on GPIO[i].
   If [`EN_INPUT_FILTER`](#en_input_filter)[i] is true, input bit [i] must be stable for 16 cycles before transitioning.
- Offset: `0x14`
- Reset default: `0x0`
- Reset mask: `0x3ff`

### Fields

```wavejson
{"reg": [{"name": "EN_RISING", "bits": 2, "attr": ["rw"], "rotate": -90}, {"name": "EN_FALLING", "bits": 2, "attr": ["rw"], "rotate": -90}, {"name": "EN_LVLHIGH", "bits": 2, "attr": ["rw"], "rotate": -90}, {"name": "EN_LVLLOW", "bits": 2, "attr": ["rw"], "rotate": -90}, {"name": "EN_INPUT_FILTER", "bits": 2, "attr": ["rw"], "rotate": -90}, {"bits": 22}], "config": {"lanes": 1, "fontsize": 10, "vspace": 170}}
```

|  Bits  |  Type  |  Reset  | Name            | Description                                                                                                                                                                                                        |
|:------:|:------:|:-------:|:----------------|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 31:10  |        |         |                 | Reserved                                                                                                                                                                                                           |
|  9:8   |   rw   |   0x0   | EN_INPUT_FILTER | filter enable for GPIO input bits. If [`CTRL_EN_INPUT_FILTER`](#ctrl_en_input_filter)[i] is true, a value of input bit [i] must be stable for 16 cycles before transitioning.                                      |
|  7:6   |   rw   |   0x0   | EN_LVLLOW       | GPIO interrupt enable for GPIO, level low. If [`INTR_ENABLE`](#intr_enable)[i] is true, a value of 1 on [`INTR_CTRL_EN_LVLLOW`](#intr_ctrl_en_lvllow)[i] enables level low interrupt detection on GPIO[i].         |
|  5:4   |   rw   |   0x0   | EN_LVLHIGH      | GPIO interrupt enable for GPIO, level high. If [`INTR_ENABLE`](#intr_enable)[i] is true, a value of 1 on [`INTR_CTRL_EN_LVLHIGH`](#intr_ctrl_en_lvlhigh)[i] enables level high interrupt detection on GPIO[i].     |
|  3:2   |   rw   |   0x0   | EN_FALLING      | GPIO interrupt enable for GPIO, falling edge. If [`INTR_ENABLE`](#intr_enable)[i] is true, a value of 1 on [`INTR_CTRL_EN_FALLING`](#intr_ctrl_en_falling)[i] enables falling-edge interrupt detection on GPIO[i]. |
|  1:0   |   rw   |   0x0   | EN_RISING       | GPIO interrupt enable for GPIO, rising edge. If [`INTR_ENABLE`](#intr_enable)[i] is true, a value of 1 on [`INTR_CTRL_EN_RISING`](#intr_ctrl_en_rising)[i] enables rising-edge interrupt detection on GPIO[i].     |

## CTRL_EN_INPUT_FILTER
filter enable for GPIO input bits.

If [`CTRL_EN_INPUT_FILTER`](#ctrl_en_input_filter)[i] is true, a value of input bit [i]
must be stable for 16 cycles before transitioning.
- Offset: `0x18`
- Reset default: `0x0`
- Reset mask: `0xf`

### Fields

```wavejson
{"reg": [{"name": "CTRL_EN_INPUT_FILTER", "bits": 4, "attr": ["rw"], "rotate": -90}, {"bits": 28}], "config": {"lanes": 1, "fontsize": 10, "vspace": 220}}
```

|  Bits  |  Type  |  Reset  | Name                 | Description   |
|:------:|:------:|:-------:|:---------------------|:--------------|
|  31:4  |        |         |                      | Reserved      |
|  3:0   |   rw   |   0x0   | CTRL_EN_INPUT_FILTER |               |

