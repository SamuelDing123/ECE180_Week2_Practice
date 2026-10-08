// Testbench for Exercise 2. Do not edit.
//
// Note: the strongest latch check is not this file -- it is Verilator's
// own LATCH warning, which `make ex2` promotes to an error. A latch that
// happens to hold the right value can still pass a functional test.
module tb_ex2;

  logic       enable;
  logic [3:0] data, y_default, y_complete, y_case;
  logic [1:0] sel;
  int         errors = 0;

  ex2_latch dut (.*);

  task automatic chk(string name, logic [3:0] got, logic [3:0] exp);
    if (got !== exp) begin
      $display("  FAIL %-11s enable=%0d data=%h sel=%0d  got=%h expected=%h",
               name, enable, data, sel, got, exp);
      errors++;
    end
  endtask

  initial begin
    sel = 2'd0;

    // Walk data with enable high, then low. If a latch survived, the
    // enable-low pass will echo whatever was last loaded instead of 0.
    for (int e = 1; e >= 0; e--) begin
      enable = e[0];
      for (int d = 0; d < 16; d++) begin
        data = d[3:0];
        #1;
        chk("y_default",  y_default,  enable ? data : 4'h0);
        chk("y_complete", y_complete, enable ? data : 4'h0);
      end
    end

    for (int s = 0; s < 4; s++) begin
      sel = s[1:0];
      #1;
      chk("y_case", y_case, 4'(1 << s));
    end

    if (errors == 0) $display("EX2 PASS  (68 checks)");
    else             $display("EX2 FAIL  (%0d errors)", errors);
    $finish;
  end

  // waveform dump: `make waveN`
  initial begin
    if ($test$plusargs("trace")) begin
      $dumpfile("build/ex2.vcd");
      $dumpvars(0, tb_ex2);
    end
  end

  // watchdog: a design that never finishes should say so, not hang the shell
  initial begin
    #200000;
    $display("EX2 TIMEOUT -- the testbench never reached the end; your design is probably stalled.");
    $fatal(1);
  end

endmodule
