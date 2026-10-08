# ECE180 Verilog Lab

A 2-hour guided SystemVerilog lab built as a companion to the lecture
*Verilog and RTL and useful design patterns*.

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
