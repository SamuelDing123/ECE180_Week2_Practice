// Testbench for Exercise 5. Do not edit.
module tb_ex5;
  import ece180_pkg::*;

  logic clk_i = 0, rst_ni;
  req_t req_i;
  rsp_t rsp_q_o;
  int   errors = 0;

  always #5 clk_i = ~clk_i;

  ex5_struct_alu dut (.*);

  // The struct is just a bit vector -- this check proves the field layout
  // is { zero, result } and not { result, zero }.
  initial begin
    if ($bits(req_t) != 18)
      $display("  NOTE req_t is %0d bits, expected 18 (op:2 + b:8 + a:8)",
               $bits(req_t));
    if ($bits(rsp_t) != 9) begin
      $display("  FAIL rsp_t is %0d bits, expected 9 (zero:1 + result:8) -- did you add the `zero` field?", $bits(rsp_t));
      errors++;
    end
  end

  task automatic drive(alu_op_e op, data_t a, data_t b, data_t exp_result);
    @(negedge clk_i);
    req_i = '{op: op, b: b, a: a};
    @(posedge clk_i); #1;          // one cycle of latency: output is registered
    if (rsp_q_o.result !== exp_result) begin
      $display("  FAIL %s(%0d,%0d).result got=%0d expected=%0d",
               op.name(), a, b, rsp_q_o.result, exp_result);
      errors++;
    end
    if (rsp_q_o.zero !== (exp_result == '0)) begin
      $display("  FAIL %s(%0d,%0d).zero   got=%0b expected=%0b",
               op.name(), a, b, rsp_q_o.zero, (exp_result == '0));
      errors++;
    end
  endtask

  initial begin
    rst_ni = 0; req_i = '0;
    repeat (2) @(posedge clk_i);
    rst_ni = 1;

    drive(ALU_ADD, 8'd3,   8'd4,  8'd7);
    drive(ALU_SUB, 8'd10,  8'd3,  8'd7);
    drive(ALU_SUB, 8'd9,   8'd9,  8'd0);    // zero flag
    drive(ALU_AND, 8'hFF,  8'hF0, 8'hF0);
    drive(ALU_AND, 8'h0F,  8'hF0, 8'h00);   // zero flag
    drive(ALU_ADD, 8'd255, 8'd1,  8'd0);    // zero flag via wrap
    drive(ALU_XOR, 8'hAA,  8'h55, 8'hFF);
    drive(ALU_XOR, 8'hAA,  8'hAA, 8'h00);   // zero flag

    if (errors == 0) $display("EX5 PASS");
    else             $display("EX5 FAIL  (%0d errors)", errors);
    $finish;
  end

  // waveform dump: `make waveN`
  initial begin
    if ($test$plusargs("trace")) begin
      $dumpfile("build/ex5.vcd");
      $dumpvars(0, tb_ex5);
    end
  end

  // watchdog: a design that never finishes should say so, not hang the shell
  initial begin
    #200000;
    $display("EX5 TIMEOUT -- the testbench never reached the end; your design is probably stalled.");
    $fatal(1);
  end

endmodule
