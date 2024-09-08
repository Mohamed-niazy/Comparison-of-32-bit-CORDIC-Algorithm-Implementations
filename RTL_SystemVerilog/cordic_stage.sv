module cordic_stage #(
    parameter NUM_SHIFTING = 1,
    WIDTH = 16
) (
    input logic signed [WIDTH-1:0] i_x,
    i_y,
    i_z,
    theta_reserved,
    input logic i_sign,
    i_mode_z,
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
    assign o_x = (i_sign) ? (i_x - (i_y >>> NUM_SHIFTING)) : (i_x + (i_y >>> NUM_SHIFTING));
  endgenerate
  assign o_y = (i_sign) ? (i_y + (i_x >>> NUM_SHIFTING)) : (i_y - (i_x >>> NUM_SHIFTING));
  assign o_z = (i_sign) ? i_z - theta_reserved : i_z + theta_reserved;

endmodule
