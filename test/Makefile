# Makefile
# See https://docs.cocotb.org/en/stable/quickstart.html for more info

# defaults
SIM ?= verilator
TOPLEVEL_LANG ?= verilog
SRC_DIR = $(PWD)/../src
PROJECT_SOURCES = tt_um_eneadim_soc.sv
ROOT := $(abspath ..)

# Forza Icarus quando il goal è di pulizia (non tocca il workflow)
ifneq ($(filter clean veryclean distclean,$(MAKECMDGOALS)),)
  SIM := icarus
endif

ifeq ($(GATES),yes)
  SIM := icarus
else
  SIM ?= verilator
endif

ifneq ($(GATES),yes)

# RTL simulation:
SIM_BUILD = sim_build/rtl
VERILOG_SOURCES := $(ROOT)/src/soc.v

# (Questi flag erano globali: li spostiamo qui e li passiamo a Verilator soltanto)
COMPILE_ARGS += --sv --timing
COMPILE_ARGS += --trace --trace-fst --trace-structs
COMPILE_ARGS += -Wno-WIDTHEXPAND
COMPILE_ARGS += -Wno-UNOPTFLAT
COMPILE_ARGS += -Wno-WIDTHTRUNC
COMPILE_ARGS += -Wno-CASEOVERLAP

else

# Gate level simulation:
SIM_BUILD = sim_build/gl
COMPILE_ARGS    += -gspecify
COMPILE_ARGS    += -DGL_TEST
COMPILE_ARGS    += -DUSE_POWER_PINS
COMPILE_ARGS    += -DSIM
COMPILE_ARGS    += -DUNIT_DELAY=\#1
VVP_ARGS        += -sdf-verbose
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v
VERILOG_SOURCES += $(PWD)/gate_level_netlist.v

#VERILOG_SOURCES += ../../flexsoc/verilog/primitives.v
#VERILOG_SOURCES += ../../flexsoc/verilog/sky130_fd_sc_hd.v
#VERILOG_SOURCES += ../runs/wokwi/final/pnl/tt_um_eneadim_soc.pnl.v

endif

COMPILE_ARGS 		+= -I$(SRC_DIR)

export COCOTB_RESULTS_FILE ?= $(abspath results.xml)

# Include the testbench sources:
VERILOG_SOURCES += $(PWD)/tb.v
TOPLEVEL = tb

# List test modules to run, separated by commas and without the .py suffix:
MODULE = test

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim

