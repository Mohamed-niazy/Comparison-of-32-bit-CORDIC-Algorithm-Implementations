
`timescale 1ns / 100ps
`define PIPELINE
`define SINGLE_STAGE
module top_syn #(
    parameter NUM_STAGES = 13,
    WIDTH = 64
) 
`ifdef PIPELINE

  (
      input logic [WIDTH-1:0] x,
      y,
      z,
      input logic mode,
      valid_in,clk_1,rst_n,
      output logic [WIDTH-1:0] cos,
      sin,
      tan_in,
      output logic  valid_out
  );
          
`else 

(
      input [WIDTH-1:0] x,
      y,
      z,
      input mode,
      output [WIDTH-1:0] cos,
      sin,
      tan_in
  );

`endif 


  c_if #(
      .NUM_STAGES(NUM_STAGES),
      .WIDTH(WIDTH)
  ) inst_if (


.clk      (clk_1    ),
.valid_in (valid_in ),
.rst_n    (rst_n    ),
.x        (x        ),
.y        (y        ),
.z        (z        ),
.mode     (mode     ),
.valid_out(valid_out),
.cos      (cos      ),
.sin      (sin      ),
.tan_in   (tan_in   )
  
  
  );

`ifdef PIPELINE
          


`ifdef SINGLE_STAGE
 cordic_singleStage #(
      .NUM_STAGES(NUM_STAGES),
      .WIDTH(WIDTH)
 ) inst_cordic_singleStage (
      .if_(inst_if.dut)
  );
 
  
`else
 cordic_pipeline #(
      .NUM_STAGES(NUM_STAGES),
      .WIDTH(WIDTH)
  ) inst_cordic__pipeline (
      .if_(inst_if.dut)
  );
 
`endif

  `else
  cordic #(
      .NUM_STAGES(NUM_STAGES),
      .WIDTH(WIDTH)
  ) inst_cordic (
      .if_(inst_if.dut)
  );

`endif

// assign inst_if.tb.clk      =           clk_1              ;     
// assign inst_if.tb.valid_in =           valid_in         ;               
// assign inst_if.tb.rst_n    =           rst_n            ;  
// assign inst_if.tb.x        =           x             ;
// assign inst_if.tb.y        =           y             ;
// assign inst_if.tb.z        =           z             ;
// assign inst_if.tb.mode     =           mode             ;
// assign valid_out        =  inst_if.dut.valid_out;            
// assign cos              =  inst_if.dut.cos      ;
// assign sin              =  inst_if.dut.sin      ;
// assign tan_in           =  inst_if.dut.tan_in   ;

endmodule
