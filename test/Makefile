# Makefile
# See https://docs.cocotb.org/en/stable/quickstart.html for more info

# defaults
SIM ?= verilator 
TOPLEVEL_LANG ?= verilog
SRC_DIR = $(PWD)/../src
PROJECT_SOURCES = tt_um_eneadim_soc.sv
ROOT := $(abspath ..)

ifneq ($(GATES),yes)

# RTL simulation:
SIM_BUILD				= sim_build/rtl
VERILOG_SOURCES := \
  $(ROOT)/ips/pkgs/top_pkg.sv \
  $(ROOT)/ips/prim/prim_reg_pkg.sv \
  $(ROOT)/ips/pkgs/prim_mubi_pkg.sv \
  $(ROOT)/ips/pkgs/prim_secded_pkg.sv \
  $(ROOT)/ips/pkgs/prim_subreg_pkg.sv \
  $(ROOT)/ips/pkgs/prim_util_pkg.sv \
  $(ROOT)/ips/pkgs/tlul_pkg.sv \
  $(ROOT)/ips/pkgs/prim_assert.sv \
  $(ROOT)/ips/pkgs/prim_count_pkg.sv \
  $(ROOT)/ips/pkgs/prim_flop_macros.sv \
  $(ROOT)/ips/pkgs/prim_alert_pkg.sv \
  $(ROOT)/ips/prim/prim_bin2gray.sv \
  $(ROOT)/ips/prim/prim_cdc_2phase.sv \
  $(ROOT)/ips/prim/prim_clk_div.sv \
  $(ROOT)/ips/prim/prim_clk_gate.sv \
  $(ROOT)/ips/prim/prim_counter.sv \
  $(ROOT)/ips/prim/prim_deglitch.sv \
  $(ROOT)/ips/prim/prim_edge_detect.sv \
  $(ROOT)/ips/prim/prim_ff.sv \
  $(ROOT)/ips/prim/prim_ff_2sync.sv \
  $(ROOT)/ips/prim/prim_fifo.sv \
  $(ROOT)/ips/prim/prim_gray2bin.sv \
  $(ROOT)/ips/prim/prim_lifo.sv \
  $(ROOT)/ips/prim/prim_lzc.sv \
  $(ROOT)/ips/prim/prim_ram.sv \
  $(ROOT)/ips/prim/prim_reg.sv \
  $(ROOT)/ips/prim/prim_rom.sv \
  $(ROOT)/ips/prim/prim_rrarbiter.sv \
  $(ROOT)/ips/prim/prim_shreg.sv \
  $(ROOT)/ips/prim_opentitan/prim_arbiter_ppc.sv \
  $(ROOT)/ips/prim_opentitan/prim_buf.sv \
  $(ROOT)/ips/prim_opentitan/prim_cdc_rand_delay.sv \
  $(ROOT)/ips/prim_opentitan/prim_count.sv \
  $(ROOT)/ips/prim_opentitan/prim_diff_decode.sv \
  $(ROOT)/ips/prim_opentitan/prim_fifo_async.sv \
  $(ROOT)/ips/prim_opentitan/prim_fifo_async_simple.sv \
  $(ROOT)/ips/prim_opentitan/prim_fifo_async_sram_adapter.sv \
  $(ROOT)/ips/prim_opentitan/prim_fifo_sync.sv \
  $(ROOT)/ips/prim_opentitan/prim_fifo_sync_cnt.sv \
  $(ROOT)/ips/prim_opentitan/prim_filter.sv \
  $(ROOT)/ips/prim_opentitan/prim_filter_ctr.sv \
  $(ROOT)/ips/prim_opentitan/prim_flop.sv \
  $(ROOT)/ips/prim_opentitan/prim_flop_2sync.sv \
  $(ROOT)/ips/prim_opentitan/prim_intr_hw.sv \
  $(ROOT)/ips/prim_opentitan/prim_onehot_check.sv \
  $(ROOT)/ips/prim_opentitan/prim_pulse_sync.sv \
  $(ROOT)/ips/prim_opentitan/prim_reg_cdc.sv \
  $(ROOT)/ips/prim_opentitan/prim_reg_cdc_arb.sv \
  $(ROOT)/ips/prim_opentitan/prim_reg_we_check.sv \
  $(ROOT)/ips/prim_opentitan/prim_sec_anchor_buf.sv \
  $(ROOT)/ips/prim_opentitan/prim_sec_anchor_flop.sv \
  $(ROOT)/ips/prim_opentitan/prim_secded_inv_39_32_dec.sv \
  $(ROOT)/ips/prim_opentitan/prim_secded_inv_39_32_enc.sv \
  $(ROOT)/ips/prim_opentitan/prim_secded_inv_64_57_dec.sv \
  $(ROOT)/ips/prim_opentitan/prim_secded_inv_64_57_enc.sv \
  $(ROOT)/ips/prim_opentitan/prim_subreg.sv \
  $(ROOT)/ips/prim_opentitan/prim_subreg_arb.sv \
  $(ROOT)/ips/prim_opentitan/prim_subreg_ext.sv \
  $(ROOT)/ips/prim_opentitan/prim_sync_reqack.sv \
  $(ROOT)/ips/prim_opentitan/prim_alert_sender.sv \
  $(ROOT)/ips/tlul/sram2tlul.sv \
  $(ROOT)/ips/tlul/tlul_adapter_host.sv \
  $(ROOT)/ips/tlul/tlul_adapter_reg.sv \
  $(ROOT)/ips/tlul/tlul_adapter_sram.sv \
  $(ROOT)/ips/tlul/tlul_assert.sv \
  $(ROOT)/ips/tlul/tlul_assert_multiple.sv \
  $(ROOT)/ips/tlul/tlul_cmd_intg_chk.sv \
  $(ROOT)/ips/tlul/tlul_cmd_intg_gen.sv \
  $(ROOT)/ips/tlul/tlul_data_integ_dec.sv \
  $(ROOT)/ips/tlul/tlul_data_integ_enc.sv \
  $(ROOT)/ips/tlul/tlul_err.sv \
  $(ROOT)/ips/tlul/tlul_err_resp.sv \
  $(ROOT)/ips/tlul/tlul_fifo_async.sv \
  $(ROOT)/ips/tlul/tlul_fifo_sync.sv \
  $(ROOT)/ips/tlul/tlul_rsp_intg_chk.sv \
  $(ROOT)/ips/tlul/tlul_rsp_intg_gen.sv \
  $(ROOT)/ips/tlul/tlul_socket_1n.sv \
  $(ROOT)/ips/tlul/tlul_socket_m1.sv \
  $(ROOT)/ips/tlul/tlul_sram_byte.sv \
  $(ROOT)/src/gpio_reg_pkg.sv \
  $(ROOT)/src/pwm_reg_pkg.sv \
  $(ROOT)/src/rv_timer_reg_pkg.sv \
  $(ROOT)/src/spi_host_reg_pkg.sv \
  $(ROOT)/src/tl_main_pkg.sv \
  $(ROOT)/src/uart_reg_pkg.sv \
  $(ROOT)/src/gpio.sv \
  $(ROOT)/src/gpio_reg_top.sv \
  $(ROOT)/src/pwm.sv \
  $(ROOT)/src/pwm_chan.sv \
  $(ROOT)/src/pwm_core.sv \
  $(ROOT)/src/pwm_reg_top.sv \
  $(ROOT)/src/rv_timer.sv \
  $(ROOT)/src/rv_timer_reg_top.sv \
  $(ROOT)/src/spi_host.sv \
  $(ROOT)/src/spi_host_core.sv \
  $(ROOT)/src/spi_host_reg_top.sv \
  $(ROOT)/src/timer_core.sv \
  $(ROOT)/src/uart.sv \
  $(ROOT)/src/uart_core.sv \
  $(ROOT)/src/uart_host_bridge.sv \
  $(ROOT)/src/uart_reg_top.sv \
  $(ROOT)/src/uart_rx.sv \
  $(ROOT)/src/uart_tx.sv \
  $(ROOT)/src/xbar_main.sv \
  $(ROOT)/src/soc.sv

else

# Gate level simulation:
SIM_BUILD				= sim_build/gl
COMPILE_ARGS    += -DGL_TEST
COMPILE_ARGS    += -DFUNCTIONAL
COMPILE_ARGS    += -DUSE_POWER_PINS
COMPILE_ARGS    += -DSIM
COMPILE_ARGS    += -DUNIT_DELAY=\#1
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v

# this gets copied in by the GDS action workflow
VERILOG_SOURCES += $(PWD)/gate_level_netlist.v

endif

# Allow sharing configuration between design and testbench via `include`:
COMPILE_ARGS 		+= -Wno-WIDTHEXPAND
COMPILE_ARGS    += --sv --timing 
COMPILE_ARGS    += --trace --trace-fst --trace-structs 
COMPILE_ARGS    += -I$(SRC_DIR) -I$(ROOT)/rtl -I$(ROOT)/ips/pkgs \
									 -I$(ROOT)/ips/prim -I$(ROOT)/ips/prim_opentitan -I$(ROOT)/ips/tlul

export COCOTB_RESULTS_FILE ?= $(abspath results.xml)

# Include the testbench sources:
VERILOG_SOURCES += $(PWD)/tb.v
TOPLEVEL = tb

# List test modules to run, separated by commas and without the .py suffix:
MODULE = test

# ---- CI-only Verilator bootstrap (no workflow change) ----
# Only run on GitHub Actions
ifeq ($(GITHUB_ACTIONS),true)

TOOLS_DIR     := $(PWD)/.tools
TOOLS_BIN     := $(TOOLS_DIR)/bin
VERILATOR_MIN := 5.036

# Put our local tools first so cocotb picks them up
export PATH := $(TOOLS_BIN):$(PATH)

# DO NOT set VERILATOR_ROOT; Verilator warns to leave it unset
# export VERILATOR_ROOT := ...   # <-- intentionally omitted

# Detect version (if any)
VERILATOR_CUR := $(shell bash -lc 'verilator --version 2>/dev/null | sed -n "s/.*Verilator \([0-9.]*\).*/\1/p"')
VERILATOR_OK  := $(shell bash -lc 'v="$(VERILATOR_CUR)"; [ -n "$$v" ] && [ $$(printf "%s\n%s\n" "$(VERILATOR_MIN)" "$$v" | sort -V | tail -1) = "$$v" ] && echo yes || echo no')

# If missing/too old, build it locally into .tools/
ifeq ($(VERILATOR_OK),no)
TOOLS_BOOTSTRAP := $(TOOLS_DIR)/.verilator-ready
.PHONY: tools
tools: $(TOOLS_BOOTSTRAP)

$(TOOLS_DIR)/.verilator-ready:
	@set -e; \
	echo "[tools] Installing Verilator >= $(VERILATOR_MIN) into $(TOOLS_DIR) ..."; \
	sudo apt-get update; \
	sudo apt-get install -y git make g++ autoconf flex bison libfl2 libfl-dev zlib1g-dev help2man ccache; \
	tmpdir=$$(mktemp -d); \
	cd "$$tmpdir"; \
	git clone --depth=1 https://github.com/verilator/verilator.git; \
	cd verilator; \
	autoconf; \
	./configure --prefix="$(TOOLS_DIR)"; \
	make -j$$(nproc); \
	make install; \
	rm -rf "$$tmpdir"; \
	echo "[tools] Using $$(which verilator)"; verilator --version; \
	touch "$@"
else
.PHONY: tools
tools:
	@echo "[tools] System Verilator ($(VERILATOR_CUR)) is OK"
endif

# Ensure we build tools before running the simulator
.DEFAULT_GOAL := all
.PHONY: all
all: tools sim

endif
# ---- end CI-only bootstrap ----



# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
