// ============================================================================
// Exercise 1 -- Three ways to describe the same wire
//
// Goal: get comfortable with `logic`, `assign`, and `always_comb`, and prove
// to yourself they are three spellings of the same hardware.
//
// Nothing here is clocked. Every output is a function of the inputs RIGHT NOW.
// If you can draw the gate, you wrote it correctly.
// ============================================================================
module ex1_comb (
    input  logic       a,
    input  logic       b,
    input  logic       sel,
    output logic       y_assign,   // a & b, written with `assign`
    output logic       y_always,   // a & b, written with `always_comb`
    output logic       y_mux,      // sel ? a : b
    output logic [1:0] y_sum       // a + b, zero-extended to 2 bits
);

  // --------------------------------------------------------------------------
  // (a) Continuous assignment. This wire is ALWAYS equal to the right-hand
  //     side. There is no "when" -- it is a permanent piece of copper.
  // --------------------------------------------------------------------------
  assign y_assign = a & b;

  // --------------------------------------------------------------------------
  // (b) The same AND gate, written procedurally.
  //
  //     `always_comb` is SystemVerilog's upgrade over `always @(*)`:
  //       - the sensitivity list is built for you and cannot be wrong
  //       - the tool ERRORS if you accidentally infer a latch
  //       - the tool ERRORS if two blocks drive the same signal
  //     Use blocking `=` inside always_comb. Always.
  //
  // TODO 1a: drive y_always with the same AND function.
  // --------------------------------------------------------------------------
  always_comb begin
    y_always = 1'b0;  // <-- replace this
  end

  // --------------------------------------------------------------------------
  // (c) A 2:1 mux. Write it with if/else inside always_comb.
  //
  //     Note the structure: EVERY path through the block assigns y_mux.
  //     That is what makes it a mux and not a latch (see Exercise 2).
  //
  // TODO 1b: y_mux = a when sel is 1, b when sel is 0.
  // --------------------------------------------------------------------------
  always_comb begin
    y_mux = 1'b0;  // <-- replace this
  end

  // --------------------------------------------------------------------------
  // (d) Width matters. `a + b` on two 1-bit values is a 1-bit add in Verilog
  //     unless the context is wider -- the carry falls off the end.
  //     y_sum is 2 bits wide, so the carry has somewhere to live.
  //
  // TODO 1c: drive y_sum with a + b.
  // --------------------------------------------------------------------------
  assign y_sum = 2'b00;  // <-- replace this

endmodule
