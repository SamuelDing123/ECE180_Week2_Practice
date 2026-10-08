// ============================================================================
// ece180_pkg.sv  --  Shared types for the ECE180 Verilog lab
//
// This is SystemVerilog's answer to a C header file. Anything declared here
// can be pulled into a module with `import ece180_pkg::*;`
//
// Read this file in Part 4. You will EDIT it in Exercise 4 and Exercise 5.
// ============================================================================
package ece180_pkg;

  // --------------------------------------------------------------------------
  // Parameters: one place to change a width that 6 files depend on.
  // --------------------------------------------------------------------------
  parameter int unsigned DATA_W = 8;

  // --------------------------------------------------------------------------
  // typedef: give a reusable name to a type.
  // Now `data_t` means "an 8-bit value" everywhere, and widening the datapath
  // is a one-line change instead of a find-and-replace across the design.
  // --------------------------------------------------------------------------
  typedef logic [DATA_W-1:0] data_t;

  // --------------------------------------------------------------------------
  // enum: a named set of encodings. The synthesizer sees `logic [1:0]`;
  // you see ALU_ADD. Waveform viewers print the NAME, not 2'b00.
  // --------------------------------------------------------------------------
  typedef enum logic [1:0] {
    ALU_ADD = 2'b00,
    ALU_SUB = 2'b01,
    ALU_AND = 2'b10
    // EXERCISE 4 TODO: add ALU_XOR = 2'b11 here.
  } alu_op_e;

  // --------------------------------------------------------------------------
  // struct packed: glue related fields into ONE value.
  //
  //   "packed" matters. A packed struct is just a bit vector with names on
  //   the slices, so it is synthesizable, can be assigned as a whole, can go
  //   through a register, and can be a module port.
  //   An UNpacked struct (no `packed` keyword) is a simulation-only container.
  //   For RTL: always write `struct packed`.
  //
  // Bit layout -- first field listed is the MOST significant:
  //
  //        [17:16]      [15:8]     [7:0]
  //      +----------+----------+----------+
  //      |    op    |     b    |     a    |
  //      +----------+----------+----------+
  //
  // So `req_t` is an 18-bit value, and `r.b` is literally `r[15:8]`.
  // --------------------------------------------------------------------------
  typedef struct packed {
    alu_op_e op;
    data_t   b;
    data_t   a;
  } req_t;

  // --------------------------------------------------------------------------
  // The reply travelling back out of the ALU.
  //
  // EXERCISE 5 TODO: add a 1-bit field named `zero` (set when result == 0).
  // Put it ABOVE `result` so the layout becomes { zero, result }.
  // --------------------------------------------------------------------------
  typedef struct packed {
    data_t result;
  } rsp_t;

endpackage
