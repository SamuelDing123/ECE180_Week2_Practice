// Testbench for Exercise 4. Do not edit.
module tb_ex4;
  import ece180_pkg::*;

  alu_op_e op_i;
  data_t   a_i, b_i, result_o;
  int      errors = 0;

  ex4_alu dut (.*);

  task automatic chk(data_t exp);
    if (result_o !== exp) begin
      $display("  FAIL op=%s a=%0d b=%0d  got=%0d expected=%0d",
               op_i.name(), a_i, b_i, result_o, exp);
      errors++;
    end
  endtask

  initial begin
    for (int i = 0; i < 40; i++) begin
      a_i = data_t'($urandom);
      b_i = data_t'($urandom);

      op_i = ALU_ADD; #1; chk(a_i + b_i);
      op_i = ALU_SUB; #1; chk(a_i - b_i);
      op_i = ALU_AND; #1; chk(a_i & b_i);
      op_i = ALU_XOR; #1; chk(a_i ^ b_i);   // needs the pkg edit
    end

    // 8-bit wraparound is part of the contract, not an accident.
    op_i = ALU_ADD; a_i = 8'd255; b_i = 8'd1; #1; chk(8'd0);
    op_i = ALU_SUB; a_i = 8'd0;   b_i = 8'd1; #1; chk(8'd255);

    if (errors == 0) $display("EX4 PASS  (162 checks)");
    else             $display("EX4 FAIL  (%0d errors)", errors);
    $finish;
  end

  // waveform dump: `make waveN`
  initial begin
    if ($test$plusargs("trace")) begin
      $dumpfile("build/ex4.vcd");
      $dumpvars(0, tb_ex4);
    end
  end

  // watchdog: a design that never finishes should say so, not hang the shell
  initial begin
    #200000;
    $display("EX4 TIMEOUT -- the testbench never reached the end; your design is probably stalled.");
    $fatal(1);
  end

endmodule
