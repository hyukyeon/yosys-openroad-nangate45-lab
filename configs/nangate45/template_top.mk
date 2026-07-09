export DESIGN_NAME = template_top
export PLATFORM    = nangate45

export REPO_ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/../..)

export VERILOG_FILES = $(REPO_ROOT)/rtl/template_top.v
export SDC_FILE      = $(REPO_ROOT)/constraints/template_top.sdc

export ABC_AREA      = 1
export CORE_UTILIZATION ?= 30
export PLACE_DENSITY_LB_ADDON = 0.20
export TNS_END_PERCENT        = 100
export SYNTH_REPEATABLE_BUILD ?= 1

# Reuse the smaller-pitch PDN setup used by the ORFS nangate45 gcd example.
export PDN_TCL ?= $(REPO_ROOT)/submodules/openroad-flow-scripts/flow/designs/nangate45/gcd/grid_strategy-M1-M4-M7.tcl
