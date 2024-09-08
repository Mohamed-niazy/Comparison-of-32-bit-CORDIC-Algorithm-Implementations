module cordic_stage_1 #(
    parameter NUM_SHIFTING = 1,
    WIDTH = 16
) (
    input logic signed [WIDTH-1:0] i_x,
    i_y,
    i_z,
    theta_reserved,
    input logic i_sign,
    i_mode_z,
    input logic [NUM_SHIFTING-1:0] num_shifting,
    output logic o_sign,
    output logic signed [WIDTH-1:0] o_x,
    o_y,
    o_z
);
  assign o_sign = (i_mode_z) ? (~o_z[WIDTH-1]) : o_y[WIDTH-1];
  generate
    // if (NUM_SHIFTING == 4)
    // assign o_x = (i_sign) ? ((i_y >>> NUM_SHIFTING)) : ((i_y >>> NUM_SHIFTING));
    // else
    assign o_x = (i_sign) ? (i_x - (i_y >>> num_shifting)) : (i_x + (i_y >>> num_shifting));
  endgenerate
  assign o_y = (i_sign) ? (i_y + (i_x >>> num_shifting)) : (i_y - (i_x >>> num_shifting));
  assign o_z = (i_sign) ? i_z - theta_reserved : i_z + theta_reserved;

endmodule


