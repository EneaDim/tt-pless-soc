import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, FallingEdge, Timer

BAUD = 115_200
BIT_TIME_PS = int(round(1e12 / BAUD))

# --- utility ---

def to_int_safe(sig):
    s = str(sig.value).lower().replace('x', '0').replace('z', '0')
    return int(s, 2)

async def apply_inputs(dut, *, ena=None, rst_n=None, ui_in=None, uio_in=None):
    """Applica solo i segnali passati come keyword-arg al PROSSIMO falling edge."""
    await FallingEdge(dut.clk)
    if ena   is not None: dut.ena.value   = int(ena) & 1
    if rst_n is not None: dut.rst_n.value = int(rst_n) & 1
    if ui_in is not None: dut.ui_in.value = int(ui_in) & 0xFF
    if uio_in is not None: dut.uio_in.value = int(uio_in) & 0xFF

# --- UART: pilota ui_in[0] sempre via apply_inputs() (falling edge) ---

async def uart_send_bit(dut, bit_val):
    ui = int(dut.ui_in.value)
    if bit_val:  ui |=  0x1
    else:        ui &= ~0x1
    await apply_inputs(dut, ui_in=ui)
    await Timer(BIT_TIME_PS, unit="ps")

async def uart_send_byte(dut, b):
    await uart_send_bit(dut, 0)                 # start
    for i in range(8):                           # LSB-first
        await uart_send_bit(dut, (b >> i) & 1)
    await uart_send_bit(dut, 1)                 # stop

async def uart_send_word32(dut, w):
    for sh in (0, 8, 16, 24):
        await uart_send_byte(dut, (w >> sh) & 0xFF)

async def uart_write32(dut, addr: int, data: int, be: int):
    # A5 | 01 | 01(WRITE) | {0000,BE} | ADDR(4B LSB-first) | DATA(4B LSB-first)
    await uart_send_byte(dut, 0xA5)
    await uart_send_byte(dut, 0x01)
    await uart_send_byte(dut, ((be & 0xF) | 0x00) & 0xFF)
    await uart_send_word32(dut, addr)
    await uart_send_word32(dut, data)

async def uart_read32(dut, addr: int):
    # A5 | 01 | 00(READ) | 0x0F | 00 | ADDR(4B LSB-first)
    await uart_send_byte(dut, 0xA5)
    await uart_send_byte(dut, 0x00)
    await uart_send_byte(dut, 0x0F)
    await uart_send_word32(dut, addr)

#
#
#async def uart_write32(dut, addr, data, be):
#    for b in (0xA5, 0x01, (be & 0xF) & 0xFF):
#        await uart_send_byte(dut, b)
#    await uart_send_word32(dut, addr)
#    await uart_send_word32(dut, data)
#
#async def uart_read32(dut, addr):
#    for b in (0xA5, 0x00, 0x0F, 0x00):
#        await uart_send_byte(dut, b)
#    await uart_send_word32(dut, addr)

# --- test ---

@cocotb.test()
async def test_uart_program_soc(dut):
    # Piccolo delay per far partire il mondo
    await Timer(12, unit="ns")

    # Clock a 40 MHz: il tb.v tiene clk=0, qui lo facciamo correre
    cocotb.start_soon(Clock(dut.clk, 20, unit="ns").start())

    # Iniziali noti (tutti applicati su falling)
    await apply_inputs(dut, ena=1, rst_n=0, ui_in=0x00, uio_in=0x00)
    # UART RX idle alto su ui_in[0]
    await apply_inputs(dut, ui_in=(int(dut.ui_in.value) | 0x01))

    # Reset basso per 64 cicli, poi rilascio (falling-safe)
    await ClockCycles(dut.clk, 64)
    await apply_inputs(dut, rst_n=1)
    await ClockCycles(dut.clk, 32)  # un po' di margine

    # ---- indirizzi di esempio (adatta ai tuoi reali) ----
    UART_BASE     = 0x8000_0000
    UART_CTRL_OFF = 0x0000_0000
    PWM_BASE      = 0x8002_0000
    PWM_EN_OFF    = 0x0000_0008
    PWM_CFG_OFF   = 0x0000_0004
    PWM_PHASE_OFF = 0x0000_0010

    # 1) abilita UART TX/RX (placeholder)
    await uart_write32(dut, UART_BASE + UART_CTRL_OFF, 0x0970_0001, be=0xF)

    # 2) configura PWM (placeholder valori)
    await uart_write32(dut, PWM_BASE + PWM_CFG_OFF,   0xB800_0010, be=0xF)
    await uart_write32(dut, PWM_BASE + PWM_PHASE_OFF, 0x0000_7FFF, be=0xF)
    await uart_write32(dut, PWM_BASE + PWM_EN_OFF,    0x0000_0001, be=0xF)

    # attesa per propagazione
    await ClockCycles(dut.clk, 1000)

    await uart_read32(dut, UART_BASE + UART_CTRL_OFF)
    await ClockCycles(dut.clk, 43000)

    # Check base sulle uscite
    uo = to_int_safe(dut.uo_out)
    dut._log.info(f"uo_out=0x{uo:02X}")
    assert ((uo << 4) & 0b11110000) != 0, "PWM enable non sembra attivo"

    # Lascia RX idle alto
    await apply_inputs(dut, ui_in=(int(dut.ui_in.value) | 0x01))

    await ClockCycles(dut.clk, 2000)

