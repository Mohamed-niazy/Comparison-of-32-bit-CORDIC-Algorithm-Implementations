`timescale 1ns / 100ps
module cordic #(
    parameter NUM_STAGES = 13,
    WIDTH = 32
) (
    c_if.dut if_
);

  logic signed [WIDTH-1:0] tan_inv_reserved[NUM_STAGES];
  logic signed [WIDTH-1:0] constant_data[5];


  logic signed [WIDTH-1:0] i_x[NUM_STAGES+1];
  logic signed [WIDTH-1:0] i_y[NUM_STAGES+1];
  logic signed [WIDTH-1:0] i_z[NUM_STAGES+1];



  logic i_sign[NUM_STAGES+1];


  initial begin
    $readmemb("./../txt_files/theta_reserved.txt", tan_inv_reserved);
    $readmemb("./../txt_files/theta_axis.txt", constant_data);
  end
  genvar i;
  generate
    begin
      for (i = 0; i < NUM_STAGES; i++) begin : gen_erate
        cordic_stage #(
            .NUM_SHIFTING(i),
            .WIDTH(WIDTH)
        ) uo (
            .i_x(i_x[i]),
            .i_y(i_y[i]),
            .i_z(i_z[i]),
            .theta_reserved(tan_inv_reserved[i]),
            .i_sign(i_sign[i]),
            .i_mode_z(if_.mode),
            .o_sign(i_sign[i+1]),
            .o_x(i_x[i+1]),
            .o_y(i_y[i+1]),
            .o_z(i_z[i+1])
        );

      end
    end
  endgenerate



  /******************************************************************/
  /******************handling inputs for stage_0*********************/
  /******************************************************************/
  always_comb begin
    i_x[0] = 'b0;
    i_y[0] = 'b0;
    i_sign[0] = if_.mode;
    i_z[0] = 'b0;
    case (if_.mode)
      'b0: begin  // tan_inverse
        i_z[0] = 'b0;
        if (~if_.x[WIDTH-1] && if_.y[WIDTH-1]) begin
          i_x[0] = -if_.y;
          i_y[0] = if_.x;
        end else if (if_.x[WIDTH-1] && if_.y[WIDTH-1]) begin
          i_x[0] = -if_.x;
          i_y[0] = -if_.y;
        end else if (if_.x[WIDTH-1] && ~if_.y[WIDTH-1]) begin
          i_x[0] = -if_.y;
          i_y[0] = -if_.x;
        end
      end
      'b1: begin  // calculate sin and cosine 
        i_x[0] = constant_data[4];
        i_y[0] = 0;
        if (if_.z >= constant_data[1]) i_z[0] = constant_data[0] - if_.z;
        else if (if_.z >= constant_data[2]) i_z[0] = if_.z - constant_data[2];
        else if (if_.z >= constant_data[3]) i_z[0] = constant_data[2] - if_.z;
        else i_z[0] = if_.z;
      end


    endcase

  end




  /*******************************************************************/
  /******************handling outputs for stage_0*********************/
  /*******************************************************************/
  always_comb begin
    if_.cos = 'b0;
    if_.sin = 'b0;
    if_.tan_in = 'b0;
    case (if_.mode)
      'b0: begin  // tan_inverse
        if (~if_.x[WIDTH-1] && if_.y[WIDTH-1]) if_.tan_in = i_z[NUM_STAGES] + constant_data[1];
        else if (if_.x[WIDTH-1] && if_.y[WIDTH-1]) if_.tan_in = i_z[NUM_STAGES] + constant_data[2];
        else if (if_.x[WIDTH-1] && ~if_.y[WIDTH-1]) if_.tan_in = i_z[NUM_STAGES] + constant_data[3];
        else if_.tan_in = i_z[NUM_STAGES];
        if_.cos = 'b0;
        if_.sin = 'b0;
      end
      'b1: begin  // calculate sin and cosine 

        if (if_.z >= constant_data[1]) begin


          if (!i_x[NUM_STAGES][WIDTH-1]) if_.cos = i_x[NUM_STAGES];
          else if_.cos = -i_x[NUM_STAGES];

          if (i_y[NUM_STAGES][WIDTH-1]) if_.sin = i_y[NUM_STAGES];
          else if_.sin = -i_y[NUM_STAGES];

        end else if (if_.z >= constant_data[2]) begin


          if (i_x[NUM_STAGES][WIDTH-1]) if_.cos = i_x[NUM_STAGES];
          else if_.cos = -i_x[NUM_STAGES];

          if (i_y[NUM_STAGES][WIDTH-1]) if_.sin = i_y[NUM_STAGES];
          else if_.sin = -i_y[NUM_STAGES];

        end else if (if_.z >= constant_data[3]) begin


          if (i_x[NUM_STAGES][WIDTH-1]) if_.cos = i_x[NUM_STAGES];
          else if_.cos = -i_x[NUM_STAGES];

          if (!i_y[NUM_STAGES][WIDTH-1]) if_.sin = i_y[NUM_STAGES];
          else if_.sin = -i_y[NUM_STAGES];

        end else begin

          if (!i_x[NUM_STAGES][WIDTH-1]) if_.cos = i_x[NUM_STAGES];
          else if_.cos = -i_x[NUM_STAGES];

          if (!i_y[NUM_STAGES][WIDTH-1]) if_.sin = i_y[NUM_STAGES];
          else if_.sin = -i_y[NUM_STAGES];

        end
        if_.tan_in = 'b0;
      end

    endcase

  end




endmodule




