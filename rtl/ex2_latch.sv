// ============================================================================
// Exercise 2 -- Latches: the bug that compiles
//
// A latch appears when a combinational block does NOT assign an output on
// every possible path. The synthesizer's reasoning is literal:
//
//     "You didn't tell me what y is when enable=0, so I must build storage
//      to remember the old value."
//
// That storage is a level-sensitive latch. It is almost never what you meant,
// it wrecks static timing analysis, and the simulation often still looks fine.
//
// Two fixes, both shown below:
//   1. Assign a DEFAULT at the top of the block, then override it.
//   2. Make the if/else (or case) complete -- every branch covered.
//
// Use `always_comb`, not `always @(*)`: always_comb makes this an ERROR
// instead of a warning you scroll past.
// ============================================================================
module ex2_latch (
    input  logic       enable,
    input  logic [3:0] data,
    input  logic [1:0] sel,
    output logic [3:0] y_default,   // fix style 1: default-then-override
    output logic [3:0] y_complete,  // fix style 2: complete if/else
    output logic [3:0] y_case       // fix style 2 applied to a case statement
);

  // --------------------------------------------------------------------------
  // THE BUG (read it, don't copy it):
  //
  //     always_comb begin
  //         if (enable)
  //             y = data;      // what is y when enable == 0?  -> LATCH
  //     end
  //
  // TODO 2a: fix it with a default assignment. Assign y_default = '0 first,
  //          then override with data when enable is high.
  //          ('0 means "zero, as wide as the target" -- use it, it never
  //           gets the width wrong.)
  // --------------------------------------------------------------------------
  always_comb begin
    y_default = '0;  // <-- keep this line, add the override below
  end

  // --------------------------------------------------------------------------
  // TODO 2b: same function, written as a complete if/else with an explicit
  //          `else`. Output data when enabled, 4'h0 otherwise.
  // --------------------------------------------------------------------------
  always_comb begin
    y_complete = '0;  // <-- replace with a complete if/else
  end

  // --------------------------------------------------------------------------
  // Case statements latch the same way: an unlisted `sel` value is an
  // unassigned path. Two cures: list every value, or write a `default`.
  //
  //   y_case = 4'd1 when sel==0
  //            4'd2 when sel==1
  //            4'd4 when sel==2
  //            4'd8 when sel==3
  //
  // TODO 2c: fill in the case. Include a `default` even though all four
  //          values of a 2-bit sel are covered -- it costs nothing and
  //          protects you when sel grows to 3 bits next quarter.
  // --------------------------------------------------------------------------
  always_comb begin
    case (sel)
      default: y_case = '0;  // <-- add the real branches
    endcase
  end

endmodule
