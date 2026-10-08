// Testbench for Exercise 1. Do not edit.
module tb_ex1;

  logic       a, b, sel;
  logic       y_assign, y_always, y_mux;
  logic [1:0] y_sum;
  int         errors = 0;

  ex1_comb dut (.*);

  task automatic chk(string name, int got, int exp);
    if (got !== exp) begin
      $display("  FAIL %-10s a=%0d b=%0d sel=%0d  got=%0d expected=%0d",
               name, a, b, sel, got, exp);
      errors++;
    end
  endtask

  initial begin
    for (int i = 0; i < 8; i++) begin
      {sel, b, a} = i[2:0];
      #1;
      chk("y_assign", y_assign, a & b);
      chk("y_always", y_always, a & b);
      chk("y_mux",    y_mux,    sel ? a : b);
      chk("y_sum",    y_sum,    a + b);
    end

    if (errors == 0) $display("EX1 PASS  (32 checks)");
    else             $display("EX1 FAIL  (%0d errors)", errors);
    $finish;
  end

  // waveform dump: `make waveN`
  initial begin
    if ($test$plusargs("trace")) begin
      $dumpfile("build/ex1.vcd");
      $dumpvars(0, tb_ex1);
    end
  end

  // watchdog: a design that never finishes should say so, not hang the shell
  initial begin
    #200000;
    $display("EX1 TIMEOUT -- the testbench never reached the end; your design is probably stalled.");
    $fatal(1);
  end

endmodule
