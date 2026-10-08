// Testbench for Exercise 6. Do not edit.
// This is "Module C: the result checker" from the lecture whiteboard problem.
module tb_ex6;
  import ece180_pkg::*;

  logic  clk_i = 0, rst_ni;
  logic  stall_i;
  logic  done;
  logic  result_valid;
  data_t result;
  int    errors = 0;
  int    seen   = 0;

  always #5 clk_i = ~clk_i;

  req_if ch ();

  ex6_source    u_a (.clk_i, .rst_ni, .ch(ch), .done_o(done));
  ex6_alu_stage u_b (.clk_i, .rst_ni, .ch(ch), .stall_i,
                     .result_valid_o(result_valid), .result_o(result));

  // Expected answers, in order.
  localparam data_t EXPECT [4] = '{8'd7, 8'd7, 8'hF0, 8'd0};

  // Module C: check every result the ALU stage announces.
  always_ff @(posedge clk_i) begin
    if (rst_ni && result_valid) begin
      if (seen >= 4) begin
        $display("  FAIL extra result %0d produced (expected only 4)", result);
        errors++;
      end else begin
        if (result !== EXPECT[seen]) begin
          $display("  FAIL result[%0d] got=%0h expected=%0h",
                   seen, result, EXPECT[seen]);
          errors++;
        end
        seen++;
      end
    end
  end

  // Protocol check: the producer may not withdraw an offer it has made.
  logic  prev_valid;
  req_t  prev_data;
  logic  prev_fire;
  always_ff @(posedge clk_i) begin
    if (rst_ni) begin
      if (prev_valid && !prev_fire && (!ch.valid || ch.data !== prev_data)) begin
        $display("  FAIL at t=%0t producer dropped or changed an unaccepted offer -- valid/data must hold until ready", $time);
        errors++;
      end
      prev_fire <= ch.valid && ch.ready;
    end
    prev_valid <= rst_ni && ch.valid;
    prev_data  <= ch.data;
  end

  initial begin
    rst_ni = 0; stall_i = 0;
    repeat (2) @(posedge clk_i);
    rst_ni = 1;

    // Stall the consumer in a ragged pattern. A correct source holds its
    // offer and loses nothing; a source that advances every cycle drops
    // requests and the checker notices.
    for (int i = 0; i < 40; i++) begin
      @(negedge clk_i);
      stall_i = ($urandom_range(0, 2) == 0);
    end
    stall_i = 0;
    repeat (6) @(posedge clk_i);

    if (seen != 4) begin
      $display("  FAIL saw %0d results, expected 4 (dropped requests under backpressure?)", seen);
      errors++;
    end
    if (!done) begin
      $display("  FAIL done_o never asserted");
      errors++;
    end

    if (errors == 0) $display("EX6 PASS  (4 results, backpressure respected)");
    else             $display("EX6 FAIL  (%0d errors)", errors);
    $finish;
  end

  // waveform dump: `make waveN`
  initial begin
    if ($test$plusargs("trace")) begin
      $dumpfile("build/ex6.vcd");
      $dumpvars(0, tb_ex6);
    end
  end

  // watchdog: a design that never finishes should say so, not hang the shell
  initial begin
    #200000;
    $display("EX6 TIMEOUT -- the testbench never reached the end; your design is probably stalled.");
    $fatal(1);
  end

endmodule
