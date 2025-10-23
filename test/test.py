# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, Timer

# ----- UART helpers -----
baud = 115_200
bit_time_ps = int(round(1e12 / baud))  # ~ 8_680_555 ps
# helper che usa i PS interi
async def uart_send_bit(dut, bit_val):
    # RX idles high su ui_in[0]
    curr = int(dut.ui_in.value)
    if bit_val:
        dut.ui_in.value = curr | 0x1
    else:
        dut.ui_in.value = curr & ~0x1
    await Timer(bit_time_ps, unit="ps")

async def uart_send_byte(dut, byte):
    await uart_send_bit(dut, 0)  # start
    for i in range(8):           # data LSB-first
        await uart_send_bit(dut, (byte >> i) & 1)
    await uart_send_bit(dut, 1)  # stop

async def uart_send_word32(dut, word):
    for sh in (0, 8, 16, 24):
        await uart_send_byte(dut, (word >> sh) & 0xFF)

async def uart_write32(dut, addr, data, be):
    # A5 | 01 | 01(WRITE) | {0000,BE} | ADDR(4B LSB-first) | DATA(4B LSB-first)
    await uart_send_byte(dut, 0xA5)
    await uart_send_byte(dut, 0x01)
    await uart_send_byte(dut, 0x01)
    await uart_send_byte(dut, ((be & 0xF) | 0x00) & 0xFF)
    await uart_send_word32(dut, addr)
    await uart_send_word32(dut, data)

async def uart_read32(dut, addr):
    # A5 | 01 | 00(READ) | 0x0F | 00 | ADDR(4B LSB-first)
    await uart_send_byte(dut, 0xA5)
    await uart_send_byte(dut, 0x01)
    await uart_send_byte(dut, 0x00)
    await uart_send_byte(dut, 0x0F)
    await uart_send_byte(dut, 0x00)
    await uart_send_word32(dut, addr)

@cocotb.test()
async def test_uart_program_soc(dut):
    # ---- clock 10ns (100 MHz) – adatta se serve ----
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())

    # ---- init IOs ----
    dut.ena.value   = 1
    dut.rst_n.value = 0
    # ui_in[0] = RX idle (1). Conserva gli altri bit di ui_in.
    dut.ui_in.value = int(dut.ui_in.value) | 0x01
    dut.uio_in.value = 0  # SPI SDI e GPIO ingressi a 0 per ora

    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 5)

    # ---- UART timing ----
    baud = 115_200  # cambia se vuoi
    bit_time_ns = 1e9 / baud  # ~8680 ns per 115200

    # ---- indirizzi di esempio: ADATTALI ai tuoi reali ----
    UART_BASE   = 0x8000_0000
    PWM_BASE    = 0x8002_0000
    PWM_EN_OFF    = 0x0000_0008
    PWM_CFG_OFF   = 0x0000_0004
    PWM_PHASE_OFF = 0x0000_0010
    UART_CTRL_OFF = 0x0000_0010

    # 1) abilita UART TX (e RX) via write al CTRL (placeholder)
    await uart_write32(dut, UART_BASE + UART_CTRL_OFF, 0x0000_0001, be=0xF)

    # 2) configura PWM (placeholder valori)
    await uart_write32(dut, PWM_BASE + PWM_CFG_OFF,   0xB800_0010, be=0xF)
    await uart_write32(dut, PWM_BASE + PWM_PHASE_OFF, 0x0000_7FFF, be=0xF)
    await uart_write32(dut, PWM_BASE + PWM_EN_OFF,    0x0000_0001, be=0xF)

    # attesa per propagazione
    await ClockCycles(dut.clk, 1000)

    # ---- check basilari su uscite wrapper ----
    # uo_out mapping: [0]=uart_tx, [1]=spi_sclk, [2]=spi_cs, [6:3]={pwm_en[1:0], pwm[1:0]}, [7]=uart_tx_en
    uo = int(dut.uo_out.value)
    dut._log.info(f"uo_out=0x{uo:02X}")
    # almeno PWM enable bit dovrebbe essere != 0 dopo write
    assert ((uo >> 3) & 0b1100) != 0, "PWM enable non sembra attivo"

    # lascia RX in idle alto
    dut.ui_in.value = int(dut.ui_in.value) | 0x01

    # attesa per propagazione
    await ClockCycles(dut.clk, 10000)

