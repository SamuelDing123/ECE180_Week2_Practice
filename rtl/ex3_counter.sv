// ============================================================================
// Exercise 3 -- Your first register: a counter
//
// This is the slide-deck example. In C:
//
//     unsigned int count = 0;
//     void increment(void) { count = (count + 1) & 31; }
//
// The C version says WHAT to compute. It says nothing about WHEN -- the
// function runs whenever something calls it.
//
// In RTL you own the "when". `always_ff @(posedge clk)` means: this value
// changes exactly once per rising clock edge, and never between edges.
// That single sentence is the whole idea behind "Register Transfer Level".
//
// ---------------------------------------------------------------------------
// `=` vs `<=`  -- the rule you should never have to think about again:
//     always_comb  -> blocking     `=`
//     always_ff    -> nonblocking  `<=`
//
// Why: `<=` means "sample all the right-hand sides, THEN update everything".
// That is exactly how a bank of flip-flops behaves on a clock edge. Using
// `=` in a clocked block makes your registers depend on the order you happened
// to write the lines in, which is how you get a design that simulates
// differently from the silicon.
// ---------------------------------------------------------------------------
//
// Reset: active-LOW here (`rst_ni`, the `_n` means "negated"). This is the
// common industry convention, and the deck's elastic buffer uses it too.
// ============================================================================
module ex3_counter #(
    parameter int unsigned WIDTH = 5,   // 5 bits -> counts 0..31, like `& 31`
    parameter int unsigned MAX   = 31
) (
    input  logic             clk_i,
    input  logic             rst_ni,   // active-low synchronous reset
    input  logic             en_i,     // only count on cycles where this is 1
    output logic [WIDTH-1:0] count_o,
    output logic             wrap_o    // 1 on the cycle count_o is at MAX and en_i
);

  logic [WIDTH-1:0] count_q;  // _q is a common suffix for "output of a flop"

  // --------------------------------------------------------------------------
  // TODO 3a: the register.
  //
  //   on reset (rst_ni == 0)  -> count_q <= '0
  //   else if (en_i)          -> count_q <= count_q + 1, wrapping to 0 at MAX
  //   else                    -> hold  (writing nothing in a clocked block
  //                                     IS "hold" -- that is legal and correct
  //                                     here, unlike in always_comb)
  //
  // Hint for the wrap: (count_q == MAX) ? '0 : count_q + 1'b1
  // --------------------------------------------------------------------------
  always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
      count_q <= '0;
    end
    // <-- add the enable / increment / wrap logic
  end

  assign count_o = count_q;

  // --------------------------------------------------------------------------
  // TODO 3b: wrap_o is COMBINATIONAL -- it is true during the cycle the
  // counter is sitting at MAX and is about to roll over.
  // Note we read count_q directly; reading a register's current value does
  // not cost you another register. (Slide: "combinational read, sequential
  // write".)
  // --------------------------------------------------------------------------
  assign wrap_o = 1'b0;  // <-- replace

endmodule
