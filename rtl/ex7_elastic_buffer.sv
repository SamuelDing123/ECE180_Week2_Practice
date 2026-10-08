// ============================================================================
// Exercise 7 (capstone) -- One-entry elastic buffer, and the lookahead trick
//
// The problem it solves: a producer and a consumer that each stall sometimes.
// Wire them directly and a stall propagates combinationally all the way back
// up the pipeline -- every stage's `ready` becomes a function of every stage
// downstream of it, and that chain of OR gates becomes your critical path.
//
// A one-entry elastic buffer (a "skid buffer") sits between them. It holds
// ONE item, so when the consumer stalls, the item already in flight has
// somewhere to land instead of being lost or back-propagated.
//
//   producer --valid/ready--> [ EB ] --valid/ready--> consumer
//
// State: just two registers.
//     full_q  -- is the slot occupied?
//     data_q  -- what is in it?
//
// ---------------------------------------------------------------------------
// THE INTERESTING PART -- registered status vs combinational lookahead
//
// When is the buffer ready to accept a new item? The obvious answer:
//
//     assign input_ready_o = !full_q;                       // (A) status only
//
// This is correct but it throws away throughput. Picture the buffer full,
// and the consumer asserting output_ready_i this cycle. The item IS leaving
// at this clock edge -- the slot WILL be empty. But (A) looked only at the
// registered status, said "full, go away", and the producer idles for a
// cycle. On a steady stream you land at 50% throughput: accept, drain,
// accept, drain.
//
//     assign input_ready_o = !full_q || output_ready_i;     // (B) lookahead
//
// (B) also considers what is about to happen at this same edge: "either I
// have room, or I am making room right now." The item leaves and a new one
// arrives on the same edge. Full throughput.
//
// The cost is real and you should know it: (B) makes input_ready_o depend
// combinationally on output_ready_i, so ready now flows backwards through
// the buffer in zero time. Chain enough of these and you have rebuilt the
// long path you were trying to break. (The usual fix at that point is a
// two-entry buffer that registers both directions.) The lesson is not
// "always use B" -- it is that you chose, and you know which you chose.
// ============================================================================
module ex7_elastic_buffer #(
    parameter int unsigned DATA_WIDTH = 8,
    // Flip this to compare the two policies. The testbench runs BOTH and
    // reports the throughput difference.
    parameter bit          LOOKAHEAD  = 1'b1
) (
    input  logic                  clk_i,
    input  logic                  rst_ni,
    input  logic                  flush_i,  // branch mispredict, pipeline flush...

    // from the producer
    input  logic                  input_valid_i,
    output logic                  input_ready_o,
    input  logic [DATA_WIDTH-1:0] input_data_i,

    // to the consumer
    output logic                  output_valid_o,
    input  logic                  output_ready_i,
    output logic [DATA_WIDTH-1:0] output_data_o
);

  logic                  full_q;
  logic [DATA_WIDTH-1:0] data_q;

  // --------------------------------------------------------------------------
  // TODO 7a: output_valid_o -- we are offering an item exactly when the slot
  // holds one. Note it must come from full_q (the REGISTERED status), never
  // from input_valid_i: the data you would be advertising lives in data_q,
  // and valid has to stay in lockstep with it.
  //
  // A flush must also mask it, so a discarded item is never handed onward.
  // --------------------------------------------------------------------------
  assign output_valid_o = 1'b0;  // <-- replace
  assign output_data_o  = data_q;

  // --------------------------------------------------------------------------
  // TODO 7b: input_ready_o -- implement BOTH policies described above and
  // select between them with the LOOKAHEAD parameter.
  //
  //     LOOKAHEAD == 0 :  !full_q
  //     LOOKAHEAD == 1 :  !full_q || output_ready_i
  //
  // Mask with rst_ni and !flush_i so a resetting or flushing buffer does not
  // promise to accept anything.
  //
  // `generate`/`if` on a parameter is the clean way to pick between two
  // structures at elaboration time -- the unused one is not built.
  // --------------------------------------------------------------------------
  generate
    if (LOOKAHEAD) begin : g_lookahead
      assign input_ready_o = 1'b0;  // <-- replace
    end else begin : g_status_only
      assign input_ready_o = 1'b0;  // <-- replace
    end
  endgenerate

  // --------------------------------------------------------------------------
  // Name the two events. Giving a handshake a name is worth doing every time:
  // `accept` and `release` read like the state machine you drew on paper,
  // and `valid && ready` scattered through a file does not.
  // --------------------------------------------------------------------------
  logic accept, release_;
  assign accept   = input_valid_i  && input_ready_o;   // an item arrives
  assign release_ = output_valid_o && output_ready_i;  // the item departs

  // --------------------------------------------------------------------------
  // TODO 7c: the state update. The priority order is the whole exercise.
  //
  //   1. reset    -> full_q <= 0, data_q <= 0
  //   2. flush    -> full_q <= 0
  //                  Flush beats everything. A flushed item must not be
  //                  delivered even if the consumer is sitting there ready
  //                  for it -- that is the point of a pipeline flush.
  //   3. accept   -> full_q <= 1, data_q <= input_data_i
  //                  Note this correctly covers the interesting case: an
  //                  item leaving and a new one arriving on the SAME edge.
  //                  The slot stays full; its contents are replaced.
  //   4. release_ -> full_q <= 0
  //                  Drained with no replacement, so the slot empties.
  //   5. otherwise-> hold
  //
  // Order matters: accept must be checked before release_, or the
  // simultaneous leave-and-arrive case would wrongly empty the buffer and
  // drop the new item.
  //
  // (Aside, for when you read the lecture slide: it writes this more
  //  compactly as `if (input_ready_o) full_q <= input_valid_i;`. That is
  //  equivalent -- but only because it hard-codes the lookahead policy,
  //  where input_ready_o is already true whenever the slot is about to
  //  free up. With LOOKAHEAD=0 that compact form hangs: ready goes low
  //  while full, so full_q would never be cleared. Worth convincing
  //  yourself of; it is a good example of how a correctness argument can
  //  quietly depend on a choice made somewhere else in the file.)
  // --------------------------------------------------------------------------
  always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
      full_q <= 1'b0;
      data_q <= '0;
    end
    // <-- flush / accept / hold
  end

endmodule
