# ============================================================================
# ECE180 Verilog lab
#
#   make ex1 ... make ex7     build + run one exercise from rtl/
#   make all                  run everything
#   make wave1 ... wave7      run and dump a waveform to build/exN.vcd
#   make clean
#
# Lint warnings are errors here on purpose: LATCH, WIDTH and CASEINCOMPLETE
# are exactly the bugs this lab is about, and they are warnings by default.
# ============================================================================

VERILATOR ?= verilator
RTL       ?= rtl

VFLAGS = --binary --timing -j 0 \
         -Wall -Wno-DECLFILENAME -Wno-UNUSEDSIGNAL -Wno-VARHIDDEN \
         -Wno-fatal \
         -Werror-LATCH -Werror-WIDTH -Werror-CASEINCOMPLETE \
         -Werror-BLKSEQ -Werror-COMBDLY -Werror-MULTIDRIVEN \
         -Werror-IMPLICIT -Werror-PINMISSING \
         --Mdir build/$(T) -o sim

PKG   = $(RTL)/ece180_pkg.sv
IFACE = $(RTL)/req_if.sv

.PHONY: all clean ex1 ex2 ex3 ex4 ex5 ex6 ex7 \
        sol1 sol2 sol3 sol4 sol5 sol6 sol7

all: ex1 ex2 ex3 ex4 ex5 ex6 ex7

# --- student exercises ------------------------------------------------------
ex1: ; @$(MAKE) --no-print-directory run T=$@ SRC="$(RTL)/ex1_comb.sv"
ex2: ; @$(MAKE) --no-print-directory run T=$@ SRC="$(RTL)/ex2_latch.sv"
ex3: ; @$(MAKE) --no-print-directory run T=$@ SRC="$(RTL)/ex3_counter.sv"
ex4: ; @$(MAKE) --no-print-directory run T=$@ SRC="$(PKG) $(RTL)/ex4_alu.sv"
ex5: ; @$(MAKE) --no-print-directory run T=$@ SRC="$(PKG) $(RTL)/ex4_alu.sv $(RTL)/ex5_struct_alu.sv"
ex6: ; @$(MAKE) --no-print-directory run T=$@ SRC="$(PKG) $(IFACE) $(RTL)/ex4_alu.sv $(RTL)/ex6_chain.sv"
ex7: ; @$(MAKE) --no-print-directory run T=$@ SRC="$(RTL)/ex7_elastic_buffer.sv"

# --- waveforms --------------------------------------------------------------
wave%: ; @$(MAKE) --no-print-directory ex$* TRACE=1

run:
	@mkdir -p build/$(T)
	@echo "=== $(T)  ($(RTL)/) ==="
	@$(VERILATOR) $(VFLAGS) $(if $(TRACE),--trace --trace-structs) \
	    --top-module tb_$(T) $(SRC) tb/tb.vlt tb/tb_$(T).sv \
	    > build/$(T)/compile.log 2>&1 \
	  || { grep -E '%(Error|Warning)' build/$(T)/compile.log | head -40; \
	       echo "  (full log: build/$(T)/compile.log)"; exit 1; }
	@grep -E '%Warning' build/$(T)/compile.log | head -20 || true
	@./build/$(T)/sim $(if $(TRACE),+trace) | grep -v '\$$finish'

clean:
	@rm -rf build *.vcd
