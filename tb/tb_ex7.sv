// Testbench for Exercise 7. Do not edit.
//
// Instantiates the buffer TWICE -- once with LOOKAHEAD=1, once with
// LOOKAHEAD=0 -- feeds both the same stream, and reports the throughput
// difference. Both must be functionally correct (no lost or reordered
// items); only the cycle count should differ.
module tb_ex7;

  localparam int unsigned W = 8;
  localparam int unsigned N = 32;

  logic clk_i = 0, rst_ni;
  int   errors = 0;

  always #5 clk_i = ~clk_i;

  // --- one instance of the scoreboarded test harness -------------------------
  // Produced with a greedy producer and an always-ready consumer, so the
  // only thing limiting throughput is the buffer's ready policy.
  logic [W-1:0] la_data, so_data;
  logic la_valid, la_ready, la_ovalid, la_oready;
  logic so_valid, so_ready, so_ovalid, so_oready;
  logic [W-1:0] la_odata, so_odata;

  ex7_elastic_buffer #(.DATA_WIDTH(W), .LOOKAHEAD(1'b1)) u_la (
      .clk_i, .rst_ni, .flush_i(1'b0),
      .input_valid_i(la_valid), .input_ready_o(la_ready), .input_data_i(la_data),
      .output_valid_o(la_ovalid), .output_ready_i(la_oready), .output_data_o(la_odata)
  );

  ex7_elastic_buffer #(.DATA_WIDTH(W), .LOOKAHEAD(1'b0)) u_so (
      .clk_i, .rst_ni, .flush_i(1'b0),
      .input_valid_i(so_valid), .input_ready_o(so_ready), .input_data_i(so_data),
      .output_valid_o(so_ovalid), .output_ready_i(so_oready), .output_data_o(so_odata)
  );

  // Greedy producers, always-ready consumers.
  assign la_valid = (la_sent < N);
  assign so_valid = (so_sent < N);
  assign la_data  = la_sent[W-1:0];
  assign so_data  = so_sent[W-1:0];
  assign la_oready = 1'b1;
  assign so_oready = 1'b1;

  int la_sent = 0, so_sent = 0, la_got = 0, so_got = 0;
  int la_cycles = 0, so_cycles = 0;

  always_ff @(posedge clk_i) begin
    if (rst_ni) begin
      if (la_valid && la_ready) la_sent <= la_sent + 1;
      if (so_valid && so_ready) so_sent <= so_sent + 1;

      if (la_ovalid && la_oready) begin
        if (la_odata !== la_got[W-1:0]) begin
          $display("  FAIL lookahead: out-of-order/corrupt item got=%0d expected=%0d",
                   la_odata, la_got);
          errors++;
        end
        la_got <= la_got + 1;
      end
      if (so_ovalid && so_oready) begin
        if (so_odata !== so_got[W-1:0]) begin
          $display("  FAIL status-only: out-of-order/corrupt item got=%0d expected=%0d",
                   so_odata, so_got);
          errors++;
        end
        so_got <= so_got + 1;
      end

      if (la_got < N) la_cycles <= la_cycles + 1;
      if (so_got < N) so_cycles <= so_cycles + 1;
    end
  end

  // --- flush behaviour -------------------------------------------------------
  logic f_valid, f_ready, f_ovalid, f_oready, f_flush;
  logic [W-1:0] f_data, f_odata;

  ex7_elastic_buffer #(.DATA_WIDTH(W), .LOOKAHEAD(1'b1)) u_f (
      .clk_i, .rst_ni, .flush_i(f_flush),
      .input_valid_i(f_valid), .input_ready_o(f_ready), .input_data_i(f_data),
      .output_valid_o(f_ovalid), .output_ready_i(f_oready), .output_data_o(f_odata)
  );

  initial begin
    rst_ni = 0; f_valid = 0; f_data = 0; f_oready = 0; f_flush = 0;
    repeat (2) @(posedge clk_i);
    rst_ni = 1;

    // Load one item, then flush it. It must never come out.
    @(negedge clk_i); f_valid = 1; f_data = 8'hA5;
    @(posedge clk_i);
    @(negedge clk_i); f_valid = 0;
    #1 if (!f_ovalid) begin
      $display("  FAIL flush test: buffer did not hold the item");
      errors++;
    end
    @(negedge clk_i); f_flush = 1;
    @(posedge clk_i);
    @(negedge clk_i); f_flush = 0; f_oready = 1;
    #1 if (f_ovalid) begin
      $display("  FAIL flushed item was still delivered");
      errors++;
    end

    // Wait for the throughput runs to drain.
    for (int i = 0; i < 400 && !(la_got == N && so_got == N); i++)
      @(posedge clk_i);
    repeat (2) @(posedge clk_i);

    $display("  lookahead   : %0d items in %0d cycles", la_got, la_cycles);
    $display("  status-only : %0d items in %0d cycles", so_got, so_cycles);

    if (la_cycles >= so_cycles) begin
      $display("  FAIL lookahead was not faster than status-only -- check your input_ready_o for LOOKAHEAD=1");
      errors++;
    end
    if (la_cycles > N + 4) begin
      $display("  FAIL lookahead took %0d cycles for %0d items; full throughput is ~1 item/cycle", la_cycles, N);
      errors++;
    end

    if (errors == 0) $display("EX7 PASS");
    else             $display("EX7 FAIL  (%0d errors)", errors);
    $finish;
  end

  // waveform dump: `make waveN`
  initial begin
    if ($test$plusargs("trace")) begin
      $dumpfile("build/ex7.vcd");
      $dumpvars(0, tb_ex7);
    end
  end

  // watchdog: a design that never finishes should say so, not hang the shell
  initial begin
    #200000;
    $display("EX7 TIMEOUT -- the testbench never reached the end; your design is probably stalled.");
    $fatal(1);
  end

endmodule
