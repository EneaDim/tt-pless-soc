# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, Timer

# ----- UART helpers -----
BAUD = 115_200
BIT_TIME_PS = int(round(1e12 / BAUD))  # ~8_680_555 ps

# Shadow per gli ingressi: mai read-modify-write dal DUT
class InputsShadow:
    def __init__(self):
        self.ui_in = 0
        self.uio_in = 0

def to_int_safe(sig):
    # Sostituisce X/Z con 0 prima del cast
    bs = sig.value.binstr.lower().replace('x', '0').replace('z', '0')
    return int(bs, 2)

async def uart_send_bit(dut, shadow: InputsShadow, bit_val):
    if bit_val:
        shadow.ui_in |= 0x1
    else:
        shadow.ui_in &= ~0x1
    dut.ui_in.value = shadow.ui_in
    await Timer(BIT_TIME_PS, unit="ps")

async def uart_send_byte(dut, shadow: InputsShadow, byte):
    await uart_send_bit(dut, shadow, 0)  # start
    for i in range(8):                   # LSB-first
        await uart_send_bit(dut, shadow, (byte >> i) & 1)
    await uart_send_bit(dut, shadow, 1)  # stop

async def uart_send_word32(dut, shadow: InputsShadow, word):
    for sh in (0, 8, 16, 24):
        await uart_send_byte(dut, shadow, (word >> sh) & 0xFF)

async def uart_write32(dut, shadow: InputsShadow, addr, data, be):
    # A5 | 01 | 01(WRITE) | {0000,BE} | ADDR(4B) | DATA(4B) — tutto LSB-first
    await uart_send_byte(dut, shadow, 0xA5)
    await uart_send_byte(dut, shadow, 0x01)
    await uart_send_byte(dut, shadow, 0x01)
    await uart_send_byte(dut, shadow, (be & 0xF) & 0xFF)
    await uart_send_word32(dut, shadow, addr)
    await uart_send_word32(dut, shadow, data)

async def uart_read32(dut, shadow: InputsShadow, addr):
    # A5 | 01 | 00(READ) | 0x0F | 00 | ADDR(4B)
    await uart_send_byte(dut, shadow, 0xA5)
    await uart_send_byte(dut, shadow, 0x01)
    await uart_send_byte(dut, shadow, 0x00)
    await uart_send_byte(dut, shadow, 0x0F)
    await uart_send_byte(dut, shadow, 0x00)
    await uart_send_word32(dut, shadow, addr)

@cocotb.test()
async def test_uart_program_soc(dut):
    # Clock (25 ns = 40 MHz; adatta se vuoi)
    cocotb.start_soon(Clock(dut.clk, 25, unit="ns").start())

    # Lascia assestare le 'initial' del tb.v (evita 0.00 ns con X/Z)
    await Timer(1, units="ns")

    shadow = InputsShadow()

    # init noti (tb.v mette già ena=1, rst_n=0, ui_in=0, uio_in=0; qui ribadiamo)
    dut.ena.value    = 1
    dut.rst_n.value  = 0
    shadow.ui_in     = 0
    shadow.uio_in    = 0
    # UART RX idle alto su ui_in[0]
    shadow.ui_in    |= 0x01
    dut.ui_in.value  = shadow.ui_in
    dut.uio_in.value = shadow.uio_in

    # reset low per qualche ciclo, poi rilascio
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 5)

    # ---- indirizzi di esempio (adattali ai tuoi) ----
    UART_BASE     = 0x8000_0000
    PWM_BASE      = 0x8002_0000
    PWM_EN_OFF    = 0x0000_0008
    PWM_CFG_OFF   = 0x0000_0004
    PWM_PHASE_OFF = 0x0000_0010
    UART_CTRL_OFF = 0x0000_0010

    # 1) abilita UART
    await uart_write32(dut, shadow, UART_BASE + UART_CTRL_OFF, 0x0BCB_0001, be=0xF)

    # 2) configura PWM
    await uart_write32(dut, shadow, PWM_BASE + PWM_CFG_OFF,   0xB800_0010, be=0xF)
    await uart_write32(dut, shadow, PWM_BASE + PWM_PHASE_OFF, 0x0000_7FFF, be=0xF)
    await uart_write32(dut, shadow, PWM_BASE + PWM_EN_OFF,    0x0000_0001, be=0xF)

    # propagazione
    await ClockCycles(dut.clk, 1000)

    # ---- check uscite wrapper ----
    # uo_out: [0]=uart_tx, [1]=spi_sclk, [2]=spi_cs, [6:3]={pwm_en[1:0], pwm[1:0]}, [7]=uart_tx_en
    uo = to_int_safe(dut.uo_out)
    dut._log.info(f"uo_out=0x{uo:02X}")
    assert ((uo >> 3) & 0b1100) != 0, "PWM enable non sembra attivo"

    # lascia RX idle alto
    shadow.ui_in |= 0x01
    dut.ui_in.value = shadow.ui_in

    await ClockCycles(dut.clk, 10_000)

