// ============================================================================
// Exercise 4 -- Packages, typedef, and enum
//
// Open rtl/ece180_pkg.sv alongside this file.
//
// Why a package exists:
//   Without one, the width of your datapath and the encoding of your opcodes
//   are copy-pasted into every module. Someone widens the bus in one file,
//   forgets the other five, and you spend an afternoon staring at a waveform.
//   A package is the single source of truth -- Verilog's include file.
//
//   package ... endpackage   declares the shared stuff
//   import pkg::*;           pulls all of it into scope
//   pkg::name                references one item without importing
//
// Why an enum beats `2'b01`:
//   - the waveform viewer prints ALU_SUB instead of 01
//   - a typo'd opcode name is a compile error; a typo'd 2'b01 is a silent bug
//   - adding an operation is one line in one file
// ============================================================================
module ex4_alu
  import ece180_pkg::*;   // note: import goes BEFORE the port list,
(                         //       so the ports can use the imported types
    input  alu_op_e op_i,
    input  data_t   a_i,
    input  data_t   b_i,
    output data_t   result_o
);

  // --------------------------------------------------------------------------
  // STEP 1 -- in rtl/ece180_pkg.sv, add the fourth opcode:
  //
  //     ALU_XOR = 2'b11
  //
  // STEP 2 -- TODO 4a: implement the ALU with a case statement over op_i.
  //
  //     ALU_ADD -> a + b
  //     ALU_SUB -> a - b
  //     ALU_AND -> a & b
  //     ALU_XOR -> a ^ b
  //
  // Because op_i is an enum you can `case (op_i)` and name the branches.
  // Keep the `default` -- a 2-bit signal can still carry X in simulation,
  // and without a default that X becomes a latch-shaped hole in your logic.
  // --------------------------------------------------------------------------
  always_comb begin
    case (op_i)
      default: result_o = '0;  // <-- add the real branches above this
    endcase
  end

endmodule
