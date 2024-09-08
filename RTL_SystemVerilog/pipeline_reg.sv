module pipeline_reg #(
    parameter WIDTH = 16
) (
    input logic signed [WIDTH-1:0] i_x,
    i_y,
    i_z,
    input logic i_mode,
    rst_n,
    clk,
    valid_in,
    i_sign,
    output logic signed [WIDTH-1:0] o_x,
    o_y,
    o_z,
    output logic valid_out,
    o_mode,
    o_sign
);
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      o_x <= 'b0;
      o_y <= 'b0;
      o_z <= 'b0;
      o_mode <= 'b0;
      o_sign <= 'b0;
      valid_out <= 'b0;
    end else begin

      o_x <= i_x;
      o_y <= i_y;
      o_z <= i_z;
      o_mode <= i_mode;
      o_sign <= i_sign;
      valid_out <= valid_in;


    end
  end
endmodule
