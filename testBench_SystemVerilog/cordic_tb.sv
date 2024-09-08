`timescale 1ns / 100ps
module tb #(
    parameter NUM_STAGES = 12,
    WIDTH = 16
) (
    c_if.tb if_
);
  int handle;
  real gr_c, gr_s, rtl_c, rtl_s;
  longint temp_gr_c, temp_gr_s, temp_rtl_c, temp_rtl_s;
  logic [WIDTH-1:0] mem[360];
  initial begin
    $dumpvars;
    $dumpfiles("tb.vcd");
    $readmemb("./../txt_files/tb_cos_sin.txt", mem);
  end

  initial begin

    int fid;
    fid = $fopen("./../txt_files/result_from_rtl.txt", "w");

    if_.x = 0;
    if_.y = 0;
    if_.z = 0;
    if_.mode = 1;
    #40;
    for (int i = 0; i < 360; i++) begin
      if_.z = mem[i];
      #10;
      extract_data(fid);
    end
    $fclose(fid);
    #10 $stop;
  end
  task extract_data(input int fid);

    $fwrite(fid, "%0d\t%0d\n", if_.cos, if_.sin);
    #2;
  endtask

endmodule
