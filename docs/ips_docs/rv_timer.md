## Summary

| Name                                     | Offset   |   Length | Description              |
|:-----------------------------------------|:---------|---------:|:-------------------------|
| rv_timer.[`CTRL`](#ctrl)                 | 0x0      |        4 | Control register         |
| rv_timer.[`INTR_ENABLE0`](#intr_enable0) | 0x4      |        4 | Interrupt Enable         |
| rv_timer.[`INTR_STATE0`](#intr_state0)   | 0x8      |        4 | Interrupt Status         |
| rv_timer.[`INTR_TEST0`](#intr_test0)     | 0xc      |        4 | Interrupt test register  |
| rv_timer.[`CFG0`](#cfg0)                 | 0x10     |        4 | Configuration for Hart 0 |
| rv_timer.[`TIMER_V0`](#timer_v0)         | 0x14     |        4 | Timer value              |
| rv_timer.[`COMPARE_V0`](#compare_v0)     | 0x18     |        4 | Timer value to compare   |

## CTRL
Control register
- Reset default: `0x0`
- Reset mask: `0x7`

### Instances

| Name   | Offset   |
|:-------|:---------|
| CTRL   | 0x0      |


### Fields

```wavejson
{"reg": [{"name": "active", "bits": 1, "attr": ["rw"], "rotate": -90}, {"name": "gpio_intr_0", "bits": 1, "attr": ["rw"], "rotate": -90}, {"name": "gpio_intr_1", "bits": 1, "attr": ["rw"], "rotate": -90}, {"bits": 29}], "config": {"lanes": 1, "fontsize": 10, "vspace": 130}}
```

|  Bits  |  Type  |  Reset  | Name        | Description                   |
|:------:|:------:|:-------:|:------------|:------------------------------|
|  31:3  |        |         |             | Reserved                      |
|   2    |   rw   |   0x0   | gpio_intr_1 | Enable timer from GPIO INTR 1 |
|   1    |   rw   |   0x0   | gpio_intr_0 | Enable timer from GPIO INTR 0 |
|   0    |   rw   |   0x0   | active      | If 1, timer operates          |

## INTR_ENABLE0
Interrupt Enable
- Offset: `0x4`
- Reset default: `0x0`
- Reset mask: `0x1`

### Fields

```wavejson
{"reg": [{"name": "IE_0", "bits": 1, "attr": ["rw"], "rotate": -90}, {"bits": 31}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name   | Description                |
|:------:|:------:|:-------:|:-------|:---------------------------|
|  31:1  |        |         |        | Reserved                   |
|   0    |   rw   |   0x0   | IE_0   | Interrupt Enable for timer |

## INTR_STATE0
Interrupt Status
- Offset: `0x8`
- Reset default: `0x0`
- Reset mask: `0x1`

### Fields

```wavejson
{"reg": [{"name": "IS_0", "bits": 1, "attr": ["rw1c"], "rotate": -90}, {"bits": 31}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name   | Description                |
|:------:|:------:|:-------:|:-------|:---------------------------|
|  31:1  |        |         |        | Reserved                   |
|   0    |  rw1c  |   0x0   | IS_0   | Interrupt status for timer |

## INTR_TEST0
Interrupt test register
- Offset: `0xc`
- Reset default: `0x0`
- Reset mask: `0x1`

### Fields

```wavejson
{"reg": [{"name": "T_0", "bits": 1, "attr": ["wo"], "rotate": -90}, {"bits": 31}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name   | Description              |
|:------:|:------:|:-------:|:-------|:-------------------------|
|  31:1  |        |         |        | Reserved                 |
|   0    |   wo   |    x    | T_0    | Interrupt test for timer |

## CFG0
Configuration for Hart 0
- Offset: `0x10`
- Reset default: `0x10000`
- Reset mask: `0xff0fff`

### Fields

```wavejson
{"reg": [{"name": "prescale", "bits": 12, "attr": ["rw"], "rotate": 0}, {"bits": 4}, {"name": "step", "bits": 8, "attr": ["rw"], "rotate": 0}, {"bits": 8}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name     | Description                     |
|:------:|:------:|:-------:|:---------|:--------------------------------|
| 31:24  |        |         |          | Reserved                        |
| 23:16  |   rw   |   0x1   | step     | Incremental value for each tick |
| 15:12  |        |         |          | Reserved                        |
|  11:0  |   rw   |   0x0   | prescale | Prescaler to generate tick      |

## TIMER_V0
Timer value
- Offset: `0x14`
- Reset default: `0x0`
- Reset mask: `0xffffffff`

### Fields

```wavejson
{"reg": [{"name": "v", "bits": 32, "attr": ["rw"], "rotate": 0}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name   | Description        |
|:------:|:------:|:-------:|:-------|:-------------------|
|  31:0  |   rw   |   0x0   | v      | Timer value [31:0] |

## COMPARE_V0
Timer value to compare
- Offset: `0x18`
- Reset default: `0xffffffff`
- Reset mask: `0xffffffff`

### Fields

```wavejson
{"reg": [{"name": "v", "bits": 32, "attr": ["rw"], "rotate": 0}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |   Reset    | Name   | Description                |
|:------:|:------:|:----------:|:-------|:---------------------------|
|  31:0  |   rw   | 0xffffffff | v      | Timer compare value [31:0] |

