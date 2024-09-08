`timescale 1ns / 100ps
module cordic_singleStage #(
    parameter NUM_STAGES = 13,
    WIDTH = 32
) (
    c_if.dut if_
);

  logic signed [WIDTH-1:0] tan_inv_reserved[NUM_STAGES];
  logic signed [WIDTH-1:0] constant_data   [         5];


  logic signed [WIDTH-1:0] i_x             [         2];
  logic signed [WIDTH-1:0] i_y             [         2];
  logic signed [WIDTH-1:0] i_z             [         2];
  logic                    i_sign          [         2];
  logic                    i_valid;
  logic                    i_mode , clk, rst_n;

assign clk=if_.clk;
assign rst_n=if_.rst_n;

  logic signed [WIDTH-1:0] temp_x;
  logic signed [WIDTH-1:0] temp_y;
  logic signed [WIDTH-1:0] temp_z;

  logic                    temp_mode;
  logic                    temp_sign;
  logic                    temp_valid;

  logic signed [WIDTH-1:0] buffer_x;
  logic signed [WIDTH-1:0] buffer_y;
  logic signed [WIDTH-1:0] buffer_z;
  logic [3:0] cnt, cnt_shifted;


  assign cnt_shifted = (cnt == 'b0) ? cnt : cnt - 1;
  initial begin
    $readmemb("./../txt_files/theta_reserved.txt", tan_inv_reserved);
    $readmemb("./../txt_files/theta_axis.txt", constant_data);
  end


  /* 
        input of  pipeline_reg      |       output of  pipeline_reg        |        input comb stage         |      input comb stage
 ------------------------------------------------------------------------------------------------------------------------------------------
           i_nameOfsignal[0]        |         temp_nameOfsignal            |       temp_nameOfsignal         |      i_nameOfsignal[1]

      */

  pipeline_reg #(
      .WIDTH(WIDTH)
  ) inst_p_reg (

      .i_x(i_x[0]),
      .i_y(i_y[0]),
      .i_z(i_z[0]),
      .i_mode(i_mode),
      .rst_n(rst_n),
      .clk(clk),
      .valid_in(i_valid),
      .i_sign(i_sign[0]),
      .o_x(temp_x),
      .o_y(temp_y),
      .o_z(temp_z),
      .valid_out(temp_valid),
      .o_mode(temp_mode),
      .o_sign(temp_sign)

  );

  cordic_stage_1 #(
      .NUM_SHIFTING(4),
      .WIDTH(WIDTH)
  ) uo (
      .i_x(temp_x),
      .i_y(temp_y),
      .i_z(temp_z),
      .theta_reserved(tan_inv_reserved[cnt_shifted]),
      .num_shifting(cnt_shifted),
      .i_sign(temp_sign),
      .i_mode_z(temp_mode),
      .o_sign(i_sign[1]),
      .o_x(i_x[1]),
      .o_y(i_y[1]),
      .o_z(i_z[1])
  );



  always @(posedge if_.clk or negedge if_.rst_n) begin
    if (!if_.rst_n) begin
      buffer_x <= 'b0;
      buffer_y <= 'b0;
      buffer_z <= 'b0;
      cnt <= 'b0;
    end else begin
      if (cnt == 'b0) begin
        if (i_valid == 'b1) begin
          buffer_x <= if_.x;
          buffer_y <= if_.y;
          buffer_z <= if_.z;
          cnt <= cnt + 1;
        end else cnt <= 'b0;
      end else if (cnt == NUM_STAGES - 1) cnt <= 0;
      else cnt <= cnt + 1;
    end
  end
  /******************************************************************/
  /******************handling inputs for stage_0*********************/
  /******************************************************************/
  always @(*) begin

    // i_x      
    // i_y      
    // i_z      
    // i_sign   
    // i_valid;
    // i_mode;





    i_x[0] = 'b0;
    i_y[0] = 'b0;
    i_z[0] = 'b0;
    i_sign[0] = if_.mode;
    i_mode = if_.mode;
    i_valid = if_.valid_in;
    if (if_.valid_in && cnt == 'b0) begin
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

    end else if (cnt == 'b0) begin

      i_valid = 0;

    end else begin

      i_x[0] = i_x[1];
      i_y[0] = i_y[1];
      i_z[0] = i_z[1];
      i_sign[0] = i_sign[1];
      i_mode = temp_mode;


    end


  end




  /*******************************************************************/
  /******************handling outputs for stage_0*********************/
  /*******************************************************************/
  always_comb begin
    if_.cos = 'b0;
    if_.sin = 'b0;
    if_.tan_in = 'b0;
    if_.valid_out = (cnt == NUM_STAGES - 1) ? 'b1 : 'b0;
    if (if_.valid_out) begin

      case (temp_mode)
        'b0: begin  // tan_inverse
          if (~buffer_x[WIDTH-1] && buffer_y[WIDTH-1]) if_.tan_in = i_z[1] + constant_data[1];
          else if (buffer_x[WIDTH-1] && buffer_y[WIDTH-1]) if_.tan_in = i_z[1] + constant_data[2];
          else if (buffer_x[WIDTH-1] && ~buffer_y[WIDTH-1]) if_.tan_in = i_z[1] + constant_data[3];
          else if_.tan_in = i_z[1];
          if_.cos = 'b0;
          if_.sin = 'b0;
        end
        'b1: begin  // calculate sin and cosine 

          if (buffer_z >= constant_data[1]) begin


            if (!i_x[1][WIDTH-1]) if_.cos = i_x[1];
            else if_.cos = -i_x[1];

            if (i_y[1][WIDTH-1]) if_.sin = i_y[1];
            else if_.sin = -i_y[1];

          end else if (buffer_z >= constant_data[2]) begin


            if (i_x[1][WIDTH-1]) if_.cos = i_x[1];
            else if_.cos = -i_x[1];

            if (i_y[1][WIDTH-1]) if_.sin = i_y[1];
            else if_.sin = -i_y[1];

          end else if (buffer_z >= constant_data[3]) begin


            if (i_x[1][WIDTH-1]) if_.cos = i_x[1];
            else if_.cos = -i_x[1];

            if (!i_y[1][WIDTH-1]) if_.sin = i_y[1];
            else if_.sin = -i_y[1];

          end else begin

            if (!i_x[1][WIDTH-1]) if_.cos = i_x[1];
            else if_.cos = -i_x[1];

            if (!i_y[1][WIDTH-1]) if_.sin = i_y[1];
            else if_.sin = -i_y[1];

          end
          if_.tan_in = 'b0;
        end

      endcase


    end

  end




endmodule




