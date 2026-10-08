// ============================================================================
// Exercise 6 -- Interfaces and modports: the whiteboard problem from lecture
//
//     Module A (source)  --req_if-->  Module B (ALU)  -->  Module C (checker)
//
//   A: every cycle it is allowed to, hand B a request {op, a, b}
//   B: compute it, hand the answer onward
//   C: check the answer (this one lives in the testbench)
//
// Everything crossing A -> B rides on one `req_if`. Notice what the port
// lists look like now, and imagine them with 20 loose signals instead.
// ============================================================================

// ----------------------------------------------------------------------------
// Module A -- trace source. Walks a small table of requests and offers them
// one at a time, respecting backpressure.
// ----------------------------------------------------------------------------
module ex6_source
  import ece180_pkg::*;
(
    input  logic       clk_i,
    input  logic       rst_ni,
    req_if.src         ch,      // <-- one port. Try driving ch.ready here and
    output logic       done_o   //     watch the compiler stop you.
);

  localparam int unsigned N    = 4;
  localparam logic [2:0]  N_IDX = 3'(N);  // same count, sized for idx_q

  // A tiny constant trace. '{...} is SystemVerilog's array/struct literal.
  localparam req_t TRACE [N] = '{
      '{op: ALU_ADD, b: 8'd4,   a: 8'd3  },   // 3 + 4   = 7
      '{op: ALU_SUB, b: 8'd3,   a: 8'd10 },   // 10 - 3  = 7
      '{op: ALU_AND, b: 8'hF0,  a: 8'hFF },   // FF & F0 = F0
      '{op: ALU_ADD, b: 8'd1,   a: 8'd255}    // 255 + 1 = 0  (wraps, 8-bit)
  };

  logic [2:0] idx_q;

  // --------------------------------------------------------------------------
  // The handshake fires when BOTH sides agree. Give that condition a name --
  // you will use it three times and it keeps the intent obvious.
  // --------------------------------------------------------------------------
  logic fire;
  assign fire = ch.valid && ch.ready;

  // --------------------------------------------------------------------------
  // TODO 6a: drive the source side of the channel.
  //
  //     ch.valid  <- 1 while idx_q is still pointing at a real entry
  //                  (i.e. idx_q < N). Combinational.
  //     ch.data   <- TRACE[idx_q]. Combinational -- and one assignment moves
  //                  all three fields, because req_t is packed.
  //     done_o    <- 1 once every entry has been handed over.
  //
  // Width note: compare idx_q against N_IDX, not N. `N` is a 32-bit int,
  // and Verilator is configured to treat implicit width extension as an error
  // -- deliberately, because a silent width mismatch is a real bug class.
  //
  // Careful: ch.valid must NOT depend on ch.ready. A producer that only
  // raises valid when it sees ready, talking to a consumer that only raises
  // ready when it sees valid, is a deadlock. Offer unconditionally.
  // --------------------------------------------------------------------------
  assign ch.valid = 1'b0;   // <-- replace
  assign ch.data  = '0;     // <-- replace
  assign done_o   = 1'b0;   // <-- replace

  // --------------------------------------------------------------------------
  // TODO 6b: advance to the next entry, but ONLY on a cycle where the
  // transfer actually happened. Advancing on every clock edge is the classic
  // way to silently drop requests the moment the consumer stalls.
  // --------------------------------------------------------------------------
  always_ff @(posedge clk_i) begin
    if (!rst_ni) idx_q <= '0;
    // <-- else if (fire) ...
  end

endmodule


// ----------------------------------------------------------------------------
// Module B -- the ALU stage. Accepts a request, registers the answer.
// ----------------------------------------------------------------------------
module ex6_alu_stage
  import ece180_pkg::*;
(
    input  logic  clk_i,
    input  logic  rst_ni,
    req_if.dst    ch,            // the consumer end of the same channel
    input  logic  stall_i,       // pretend downstream backpressure, for testing
    output logic  result_valid_o,
    output data_t result_o
);

  // --------------------------------------------------------------------------
  // TODO 6c: ch.ready -- we can accept a request on any cycle we are not
  // being stalled. This is the consumer's half of the handshake, and it is
  // the ONLY signal this module is allowed to drive on `ch`.
  // --------------------------------------------------------------------------
  assign ch.ready = 1'b0;  // <-- replace

  logic fire;
  assign fire = ch.valid && ch.ready;

  // --------------------------------------------------------------------------
  // TODO 6d: register the result.
  //
  //     result_valid_o <= fire                 (did we take something?)
  //     result_o       <= the ALU answer for ch.data, when fire
  //
  // Reach into the bundle with `.`: ch.data.op, ch.data.a, ch.data.b.
  // Easiest correct answer: instantiate ex4_alu and drive it from ch.data.
  // --------------------------------------------------------------------------
  data_t alu_result;

  ex4_alu u_alu (
      .op_i    (ch.data.op),
      .a_i     (ch.data.a),
      .b_i     (ch.data.b),
      .result_o(alu_result)
  );

  always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
      result_valid_o <= 1'b0;
      result_o       <= '0;
    end
    // <-- else: capture alu_result when the handshake fires
  end

endmodule
