# ECE180 Verilog Lab

A 2-hour guided SystemVerilog lab built as a companion to the lecture
*Verilog and RTL and useful design patterns*.

**Start here: [`WORKBOOK.md`](WORKBOOK.md)**

## Quick start

```bash
verilator --version     # need 5.0+;  apt-get install verilator  /  brew install verilator
make ex1                # your turn
```

## Layout

```
WORKBOOK.md    the lab itself — read this
Makefile
rtl/           students edit these; every TODO lives here
tb/            testbenches (the grader) — do not edit
```

## Targets

| | |
|---|---|
| `make exN` | build + run exercise N from `rtl/` |
| `make all` | run all seven |
| `make waveN` | run and dump `build/exN/exN.vcd` |
| `make clean` | |

## Exercises

| | Topic | Files |
|---|---|---|
| 1 | `logic`, `assign`, `always_comb` | `ex1_comb.sv` |
| 2 | Latches and how to avoid them | `ex2_latch.sv` |
| 3 | `always_ff`, a counter, `=` vs `<=` | `ex3_counter.sv` |
| 4 | Packages, `typedef`, `enum` | `ece180_pkg.sv`, `ex4_alu.sv` |
| 5 | **Packed structs** | `ece180_pkg.sv`, `ex5_struct_alu.sv` |
| 6 | Interfaces, `modport`, valid/ready | `req_if.sv`, `ex6_chain.sv` |
| 7 | Elastic buffer, registered status vs lookahead | `ex7_elastic_buffer.sv` |

## For instructors

Lint warnings are promoted to errors (`LATCH`, `WIDTH`, `CASEINCOMPLETE`,
`BLKSEQ`, `COMBDLY`, `MULTIDRIVEN`) — these are the bug classes the lecture
covers, and a default flow lets them scroll past as yellow text.

Every testbench is self-checking, prints `EXn PASS`/`FAIL` with specific
diagnostics, and carries a watchdog so a stalled design reports a timeout
instead of hanging a terminal. Exercise 6 additionally checks the
valid-stability protocol rule; exercise 7 instantiates the buffer under both
ready policies and asserts that lookahead is measurably faster.

Exercises 4 and 5 require edits to `rtl/ece180_pkg.sv` (adding `ALU_XOR` and
the `zero` field) and will not compile until those are made — deliberately, so
students have to open the package.
