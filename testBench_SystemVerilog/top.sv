
`timescale 1ns / 100ps
// `define PIPELINE
// `define SINGLE_STAGE
`define MULTI_STAGE
`define TEST_MODE
module top #(
    parameter NUM_STAGES = 13,
    WIDTH = 32
) ();
  c_if #(
      .NUM_STAGES(NUM_STAGES),
      .WIDTH(WIDTH)
  ) inst_if ();

`ifdef PIPELINE
  cordic_pipeline #(
      .NUM_STAGES(NUM_STAGES),
      .WIDTH(WIDTH)
  ) inst_cordic__pipeline (
      .if_(inst_if.dut)
  );
  tb_pipeline #(
      .NUM_STAGES(NUM_STAGES),
      .WIDTH(WIDTH)
  ) inst_tb__pipeline (
      .if_(inst_if.tb)
  );
`endif

`ifdef SINGLE_STAGE
  cordic_singleStage #(
      .NUM_STAGES(NUM_STAGES),
      .WIDTH(WIDTH)
  ) inst_cordic_singleStage (
      .if_(inst_if.dut)
  );
  tb_singleStage #(
      .NUM_STAGES(NUM_STAGES),
      .WIDTH(WIDTH)
  ) inst_tb_singleStage (
      .if_(inst_if.tb)
  );
`endif

`ifdef MULTI_STAGE
  cordic #(
      .NUM_STAGES(NUM_STAGES),
      .WIDTH(WIDTH)
  ) inst_cordic (
      .if_(inst_if.dut)
  );

  tb #(
      .NUM_STAGES(NUM_STAGES),
      .WIDTH(WIDTH)
  ) inst_tb (
      .if_(inst_if.tb)
  );
`else
  always #1 inst_if.clk = ~inst_if.clk;
`endif


endmodule
