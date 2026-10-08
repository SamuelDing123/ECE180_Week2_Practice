// ============================================================================
// Exercise 5 -- Packed structs
//
// THE motivating problem. A real decoded instruction has ~20 fields. Carried
// as loose signals, every pipeline stage looks like this:
//
//     module stage (
//         input logic [4:0] rs1_i, input logic [4:0] rs2_i,
//         input logic uses_rs1_i,  input logic uses_rs2_i,
//         input logic [3:0] alu_op_i, input logic [31:0] imm_i,
//         ...  // and 14 more, repeated in every stage, in a fixed order
//     );
//
// Add one field and you edit six files, six instantiations, and six pipeline
// registers. Swap two ports of the same width at an instantiation and it
// compiles silently and simulates wrong.
//
// With a packed struct the whole bundle is ONE signal:
//
//     module stage (input req_t req_i, output rsp_t rsp_o);
//
// A packed struct is a plain bit vector underneath -- `req_t` is just 18 bits
// with names on the slices. So it is fully synthesizable, you can clock it
// through a register in one line, and `.` access is free (it's wiring).
//
//     req_t r;
//     r.a  = 8'd3;        // write one field
//     r.op = ALU_ADD;
//     q <= r;             // push the whole bundle through a flop, one line
//     $display("%p", r);  // %p prints a struct nicely in simulation
//
// REMEMBER: `struct packed`, never a bare `struct`. An unpacked struct is a
// simulation-only container -- it is not a bit vector and will not synthesize.
// ============================================================================
module ex5_struct_alu
  import ece180_pkg::*;
(
    input  logic clk_i,
    input  logic rst_ni,
    input  req_t req_i,     // one port instead of three
    output rsp_t rsp_q_o    // one port instead of two, registered
);

  rsp_t rsp_d;  // _d = the value heading INTO a flop, _q = coming OUT.
                //      A convention worth adopting; it makes a schematic
                //      out of your variable names.

  // --------------------------------------------------------------------------
  // STEP 1 -- in rtl/ece180_pkg.sv, add a `zero` field to rsp_t, above
  //           `result`, so the struct becomes { zero, result }.
  //
  // STEP 2 -- TODO 5a: compute rsp_d combinationally from req_i.
  //
  //     rsp_d.result = the ALU result for req_i.op on req_i.a / req_i.b
  //     rsp_d.zero   = 1 when that result is all zeros
  //
  //   You may instantiate ex4_alu here instead of rewriting the case --
  //   reusing the module you already debugged is the better answer, and
  //   accessing `req_i.a` at an instantiation port is perfectly legal.
  // --------------------------------------------------------------------------
  always_comb begin
    rsp_d = '0;  // <-- '0 on a struct zeroes every field at once. Replace.
  end

  // --------------------------------------------------------------------------
  // TODO 5b: register the whole struct in ONE nonblocking assignment.
  //          This is the payoff: it does not matter how many fields rsp_t
  //          grows later, this line never changes.
  // --------------------------------------------------------------------------
  always_ff @(posedge clk_i) begin
    if (!rst_ni) rsp_q_o <= '0;
    // <-- else, capture rsp_d
  end

endmodule
