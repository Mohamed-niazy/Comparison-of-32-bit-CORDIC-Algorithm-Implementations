`timescale 1ns / 100ps
//`define PIPELINE
//`define SINGLE_STAGE
`define MULTI_STAGE
interface c_if #(
    parameter NUM_STAGES = 13,
    WIDTH = 32
) ();

  logic signed [WIDTH-1:0] x, y, z, cos, sin, tan_in;
  logic mode;

`ifndef MULTI_STAGE
  bit clk;
  logic rst_n, valid_out, valid_in;
  modport dut(input x, y, z, mode, rst_n, clk, valid_in, output cos, sin, tan_in, valid_out);
  modport tb(output x, y, z, mode, rst_n, clk, valid_in, input cos, sin, tan_in, valid_out);
`else
  modport dut(input x, y, z, mode, output cos, sin, tan_in);
  modport tb(output x, y, z, mode, input cos, sin, tan_in);
`endif

endinterface  //c_if
