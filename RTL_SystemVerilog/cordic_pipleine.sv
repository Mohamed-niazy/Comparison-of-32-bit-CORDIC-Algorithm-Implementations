`timescale 1ns / 100ps
module cordic_pipleine #(
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



  logic signed [WIDTH-1:0] temp_x[NUM_STAGES+1];
  logic signed [WIDTH-1:0] temp_y[NUM_STAGES+1];
  logic signed [WIDTH-1:0] temp_z[NUM_STAGES+1];

  logic i_sign[NUM_STAGES+1];
  logic temp_mode[NUM_STAGES+1];
  logic temp_sign[NUM_STAGES+1];
  logic temp_valid[NUM_STAGES+1];

  logic signed [WIDTH-1:0] buffer_x[NUM_STAGES+1];
  logic signed [WIDTH-1:0] buffer_y[NUM_STAGES+1];
  logic signed [WIDTH-1:0] buffer_z[NUM_STAGES+1];


  initial begin
    // $readmemb("./../txt_files/theta_reserved.txt", tan_inv_reserved);
    // $readmemb("./../txt_files/theta_axis.txt", constant_data);
    $readmemb("./../txt_files/theta_reserved.txt", tan_inv_reserved);
    $readmemb("./../txt_files/theta_axis.txt", constant_data);
  end
  genvar i;
  generate
    begin

      /* 
        input of  pipeline_reg      |       output of  pipeline_reg        |        input comb stage         |      input comb stage
 ------------------------------------------------------------------------------------------------------------------------------------------
           i_nameOfsignal[i]        |         temp_nameOfsignal[i]         |       temp_nameOfsignal[i]      |      i_nameOfsignal[i+1]


           //////////////////excepted valid and mode signal////////////////////////
      */
      for (i = 0; i < NUM_STAGES; i++) begin : gen_erate
        cordic_stage #(
            .NUM_SHIFTING(i),
            .WIDTH(WIDTH)
        ) uo (
            .i_x(temp_x[i]),
            .i_y(temp_y[i]),
            .i_z(temp_z[i]),
            .theta_reserved(tan_inv_reserved[i]),
            .i_sign(temp_sign[i]),
            .i_mode_z(temp_mode[i+1]),
            .o_sign(i_sign[i+1]),
            .o_x(i_x[i+1]),
            .o_y(i_y[i+1]),
            .o_z(i_z[i+1])
        );

        pipeline_reg #(
            .WIDTH(WIDTH)
        ) inst_p_reg (

            .i_x(i_x[i]),
            .i_y(i_y[i]),
            .i_z(i_z[i]),
            .i_mode(temp_mode[i]),
            .rst_n(if_.rst_n),
            .clk(if_.clk),
            .valid_in(temp_valid[i]),
            .i_sign(i_sign[i]),
            .o_x(temp_x[i]),
            .o_y(temp_y[i]),
            .o_z(temp_z[i]),
            .valid_out(temp_valid[i+1]),
            .o_mode(temp_mode[i+1]),
            .o_sign(temp_sign[i])

        );
      end
    end



    always @(posedge if_.clk) begin

      for (int i = 0; i < NUM_STAGES; i++) begin

        buffer_x[i+1] <= buffer_x[i];
        buffer_y[i+1] <= buffer_y[i];
        buffer_z[i+1] <= buffer_z[i];

      end
    end

  endgenerate



  /******************************************************************/
  /******************handling inputs for stage_0*********************/
  /******************************************************************/
  always @(*) begin
    i_x[0] = 'b0;
    i_y[0] = 'b0;
    i_sign[0] = if_.mode;
    temp_mode[0] = if_.mode;
    i_z[0] = 'b0;
    temp_valid[0] = if_.valid_in;
    if (if_.valid_in) begin
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

    buffer_x[0] = if_.x;
    buffer_y[0] = if_.y;
    buffer_z[0] = if_.z;

  end




  /*******************************************************************/
  /******************handling outputs for stage_0*********************/
  /*******************************************************************/
  always_comb begin
    if_.cos = 'b0;
    if_.sin = 'b0;
    if_.tan_in = 'b0;
    if_.valid_out = temp_valid[NUM_STAGES];
    if (if_.valid_out) begin

      case (temp_mode[NUM_STAGES])
        'b0: begin  // tan_inverse
          if (~buffer_x[NUM_STAGES][WIDTH-1] && buffer_y[NUM_STAGES][WIDTH-1])
            if_.tan_in = i_z[NUM_STAGES] + constant_data[1];
          else if (buffer_x[NUM_STAGES][WIDTH-1] && buffer_y[NUM_STAGES][WIDTH-1])
            if_.tan_in = i_z[NUM_STAGES] + constant_data[2];
          else if (buffer_x[NUM_STAGES][WIDTH-1] && ~buffer_y[NUM_STAGES][WIDTH-1])
            if_.tan_in = i_z[NUM_STAGES] + constant_data[3];
          else if_.tan_in = i_z[NUM_STAGES];
          if_.cos = 'b0;
          if_.sin = 'b0;
        end
        'b1: begin  // calculate sin and cosine 

          if (buffer_z[NUM_STAGES] >= constant_data[1]) begin


            if (!i_x[NUM_STAGES][WIDTH-1]) if_.cos = i_x[NUM_STAGES];
            else if_.cos = -i_x[NUM_STAGES];

            if (i_y[NUM_STAGES][WIDTH-1]) if_.sin = i_y[NUM_STAGES];
            else if_.sin = -i_y[NUM_STAGES];

          end else if (buffer_z[NUM_STAGES] >= constant_data[2]) begin


            if (i_x[NUM_STAGES][WIDTH-1]) if_.cos = i_x[NUM_STAGES];
            else if_.cos = -i_x[NUM_STAGES];

            if (i_y[NUM_STAGES][WIDTH-1]) if_.sin = i_y[NUM_STAGES];
            else if_.sin = -i_y[NUM_STAGES];

          end else if (buffer_z[NUM_STAGES] >= constant_data[3]) begin


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

  end




endmodule




