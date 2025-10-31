## Summary

| Name                               | Offset   |   Length | Description                |
|:-----------------------------------|:---------|---------:|:---------------------------|
| uart.[`CTRL`](#ctrl)               | 0x0      |        4 | UART control register      |
| uart.[`STATUS`](#status)           | 0x4      |        4 | UART live status register  |
| uart.[`RDATA`](#rdata)             | 0x8      |        4 | UART read data             |
| uart.[`WDATA`](#wdata)             | 0xc      |        4 | UART write data            |
| uart.[`FIFO_CTRL`](#fifo_ctrl)     | 0x10     |        4 | UART FIFO control register |
| uart.[`FIFO_STATUS`](#fifo_status) | 0x14     |        4 | UART FIFO status register  |

## CTRL
UART control register
- Offset: `0x0`
- Reset default: `0x4b7f0000`
- Reset mask: `0xffff00f7`

### Fields

```wavejson
{"reg": [{"name": "TX", "bits": 1, "attr": ["rw"], "rotate": -90}, {"name": "RX", "bits": 1, "attr": ["rw"], "rotate": -90}, {"name": "NF", "bits": 1, "attr": ["rw"], "rotate": -90}, {"bits": 1}, {"name": "SLPBK", "bits": 1, "attr": ["rw"], "rotate": -90}, {"name": "LLPBK", "bits": 1, "attr": ["rw"], "rotate": -90}, {"name": "PARITY_EN", "bits": 1, "attr": ["rw"], "rotate": -90}, {"name": "PARITY_ODD", "bits": 1, "attr": ["rw"], "rotate": -90}, {"bits": 8}, {"name": "NCO", "bits": 16, "attr": ["rw"], "rotate": 0}], "config": {"lanes": 1, "fontsize": 10, "vspace": 120}}
```

|  Bits  |  Type  |  Reset  | Name       | Description                                                                                                                                                                                                    |
|:------:|:------:|:-------:|:-----------|:---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 31:16  |   rw   | 0x4b7f  | NCO        | BAUD clock rate control. Reset value for 115200 baud at 100MHz                                                                                                                                                 |
|  15:8  |        |         |            | Reserved                                                                                                                                                                                                       |
|   7    |   rw   |   0x0   | PARITY_ODD | If PARITY_EN is true, this determines the type, 1 for odd parity, 0 for even.                                                                                                                                  |
|   6    |   rw   |   0x0   | PARITY_EN  | If true, parity is enabled in both RX and TX directions.                                                                                                                                                       |
|   5    |   rw   |   0x0   | LLPBK      | Line loopback enable. If this bit is turned on, incoming bits are forwarded to TX for testing purpose. See Block Diagram. Note that the internal design sees RX value as 1 always if line loopback is enabled. |
|   4    |   rw   |   0x0   | SLPBK      | System loopback enable. If this bit is turned on, any outgoing bits to TX are received through RX. See Block Diagram. Note that the TX line goes 1 if System loopback is enabled.                              |
|   3    |        |         |            | Reserved                                                                                                                                                                                                       |
|   2    |   rw   |   0x0   | NF         | RX noise filter enable. If the noise filter is enabled, RX line goes through the 3-tap repetition code. It ignores single IP clock period noise.                                                               |
|   1    |   rw   |   0x0   | RX         | RX enable                                                                                                                                                                                                      |
|   0    |   rw   |   0x0   | TX         | TX enable                                                                                                                                                                                                      |

## STATUS
UART live status register
- Offset: `0x4`
- Reset default: `0x3c`
- Reset mask: `0x3f`

### Fields

```wavejson
{"reg": [{"name": "TXFULL", "bits": 1, "attr": ["ro"], "rotate": -90}, {"name": "RXFULL", "bits": 1, "attr": ["ro"], "rotate": -90}, {"name": "TXEMPTY", "bits": 1, "attr": ["ro"], "rotate": -90}, {"name": "TXIDLE", "bits": 1, "attr": ["ro"], "rotate": -90}, {"name": "RXIDLE", "bits": 1, "attr": ["ro"], "rotate": -90}, {"name": "RXEMPTY", "bits": 1, "attr": ["ro"], "rotate": -90}, {"bits": 26}], "config": {"lanes": 1, "fontsize": 10, "vspace": 90}}
```

|  Bits  |  Type  |  Reset  | Name    | Description                                         |
|:------:|:------:|:-------:|:--------|:----------------------------------------------------|
|  31:6  |        |         |         | Reserved                                            |
|   5    |   ro   |   0x1   | RXEMPTY | RX FIFO is empty                                    |
|   4    |   ro   |   0x1   | RXIDLE  | RX is idle                                          |
|   3    |   ro   |   0x1   | TXIDLE  | TX FIFO is empty and all bits have been transmitted |
|   2    |   ro   |   0x1   | TXEMPTY | TX FIFO is empty                                    |
|   1    |   ro   |    x    | RXFULL  | RX buffer is full                                   |
|   0    |   ro   |    x    | TXFULL  | TX buffer is full                                   |

## RDATA
UART read data
- Offset: `0x8`
- Reset default: `0x0`
- Reset mask: `0xff`

### Fields

```wavejson
{"reg": [{"name": "RDATA", "bits": 8, "attr": ["ro"], "rotate": 0}, {"bits": 24}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name   | Description   |
|:------:|:------:|:-------:|:-------|:--------------|
|  31:8  |        |         |        | Reserved      |
|  7:0   |   ro   |    x    | RDATA  |               |

## WDATA
UART write data
- Offset: `0xc`
- Reset default: `0x0`
- Reset mask: `0xff`

### Fields

```wavejson
{"reg": [{"name": "WDATA", "bits": 8, "attr": ["wo"], "rotate": 0}, {"bits": 24}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name   | Description   |
|:------:|:------:|:-------:|:-------|:--------------|
|  31:8  |        |         |        | Reserved      |
|  7:0   |   wo   |   0x0   | WDATA  |               |

## FIFO_CTRL
UART FIFO control register
- Offset: `0x10`
- Reset default: `0x0`
- Reset mask: `0x3`

### Fields

```wavejson
{"reg": [{"name": "RXRST", "bits": 1, "attr": ["wo"], "rotate": -90}, {"name": "TXRST", "bits": 1, "attr": ["wo"], "rotate": -90}, {"bits": 30}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name   | Description                                                           |
|:------:|:------:|:-------:|:-------|:----------------------------------------------------------------------|
|  31:2  |        |         |        | Reserved                                                              |
|   1    |   wo   |   0x0   | TXRST  | TX fifo reset. Write 1 to the register resets TX_FIFO. Read returns 0 |
|   0    |   wo   |   0x0   | RXRST  | RX fifo reset. Write 1 to the register resets RX_FIFO. Read returns 0 |

## FIFO_STATUS
UART FIFO status register
- Offset: `0x14`
- Reset default: `0x0`
- Reset mask: `0xff00ff`

### Fields

```wavejson
{"reg": [{"name": "TXLVL", "bits": 8, "attr": ["ro"], "rotate": 0}, {"bits": 8}, {"name": "RXLVL", "bits": 8, "attr": ["ro"], "rotate": 0}, {"bits": 8}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name   | Description                   |
|:------:|:------:|:-------:|:-------|:------------------------------|
| 31:24  |        |         |        | Reserved                      |
| 23:16  |   ro   |    x    | RXLVL  | Current fill level of RX fifo |
|  15:8  |        |         |        | Reserved                      |
|  7:0   |   ro   |    x    | TXLVL  | Current fill level of TX fifo |

