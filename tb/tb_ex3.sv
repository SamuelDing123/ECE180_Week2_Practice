// Testbench for Exercise 3. Do not edit.
module tb_ex3;

  localparam int unsigned W   = 5;
  localparam int unsigned MAX = 31;

  logic         clk_i = 0, rst_ni, en_i;
  logic [W-1:0] count_o;
  logic         wrap_o;
  int           errors = 0;
  int           model;

  always #5 clk_i = ~clk_i;

  ex3_counter #(.WIDTH(W), .MAX(MAX)) dut (.*);

  task automatic chk(string name, int got, int exp);
    if (got !== exp) begin
      $display("  FAIL %-8s t=%0t  got=%0d expected=%0d", name, $time, got, exp);
      errors++;
    end
  endtask

  initial begin
    rst_ni = 0; en_i = 0;
    @(posedge clk_i); #1;
    chk("reset", count_o, 0);
    rst_ni = 1;

    // Hold with enable low -- the counter must not move.
    en_i = 0;
    repeat (3) @(posedge clk_i);
    #1 chk("hold", count_o, 0);

    // Count through a full wrap and a bit beyond.
    model = 0;
    en_i  = 1;
    for (int i = 0; i < MAX + 5; i++) begin
      #1 chk("wrap_o", wrap_o, (model == MAX) ? 1 : 0);
      @(posedge clk_i);
      model = (model == MAX) ? 0 : model + 1;
      #1 chk("count", count_o, model);
    end

    // Gaps in enable must not be counted.
    en_i = 0;
    repeat (4) @(posedge clk_i);
    #1 chk("hold2", count_o, model);
    chk("wrap_lo", wrap_o, 0);

    if (errors == 0) $display("EX3 PASS");
    else             $display("EX3 FAIL  (%0d errors)", errors);
    $finish;
  end

  // waveform dump: `make waveN`
  initial begin
    if ($test$plusargs("trace")) begin
      $dumpfile("build/ex3.vcd");
      $dumpvars(0, tb_ex3);
    end
  end

  // watchdog: a design that never finishes should say so, not hang the shell
  initial begin
    #200000;
    $display("EX3 TIMEOUT -- the testbench never reached the end; your design is probably stalled.");
    $fatal(1);
  end

endmodule
