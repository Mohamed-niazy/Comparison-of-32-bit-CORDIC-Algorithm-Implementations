`timescale 1ns / 100ps
module tb_singleStage #(
    parameter NUM_STAGES = 12,
    WIDTH = 16
) (
    c_if.tb if_
);
  int q;
  logic [WIDTH-1:0] mem[360];
  int fid;
  task extract_data_for_matlab(input int fid);
    fid = $fopen("./../txt_files/result_from_rtl_singleStage.txt", "w");
    forever begin
      @(posedge if_.valid_out) @(negedge if_.clk) $fwrite(fid, "%0d\t%0d\n", if_.cos, if_.sin);
    end
  endtask
  task load_mem();
    begin
      $dumpvars;
      $dumpfiles("tb.vcd");
      $readmemb("./../txt_files/tb_cos_sin.txt", mem);

    end
  endtask

  task initialize();

    if_.x = 0;
    if_.y = 0;
    if_.z = 0;
    if_.mode = 1;
    if_.valid_in = 'b0;
    if_.rst_n = 'b1;
  endtask

  task reset();
    begin
      if_.rst_n = 'b0;
      repeat (2) @(posedge if_.clk);
      if_.rst_n = 'b1;

    end
  endtask
  task enter_data(input int i);
    if_.z = mem[i];
    if_.valid_in = 'b1;
    @(posedge if_.clk) if_.valid_in = 'b0;
    @(negedge if_.valid_out);
  endtask

  initial begin
    load_mem();
    initialize();
    reset();
    fork
      begin
        for (int i = 0; i < 360; i++) begin
          enter_data(i);
          q = i;
        end
        @(negedge if_.clk) @(negedge if_.clk) $fclose(fid);
        $stop;
      end
      begin
        extract_data_for_matlab(fid);
      end
    join
  end
endmodule
