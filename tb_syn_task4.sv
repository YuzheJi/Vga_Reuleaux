`timescale 1ps/1ps
module tb_syn_task4();

integer file;
logic clk;
logic [19:0] finished;
logic [14:0] clk_counter;

logic [3:0] KEY; logic [9:0] SW; logic [9:0] LEDR;
logic [6:0] HEX0; logic [6:0] HEX1; logic [6:0] HEX2;
logic [6:0] HEX3; logic [6:0] HEX4; logic [6:0] HEX5;
logic [7:0] VGA_R; logic [7:0] VGA_G; logic [7:0] VGA_B;
logic [7:0] VGA_X; logic [6:0] VGA_Y;
logic VGA_HS; logic VGA_VS; logic VGA_CLK;
logic [2:0] VGA_COLOUR; logic VGA_PLOT;

task4 DUT (.CLOCK_50(clk), .KEY(KEY), .SW(SW), .LEDR(LEDR), 
            .HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2), .HEX3(HEX3), .HEX4(HEX4), .HEX5(HEX5),
            .VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B), .VGA_HS(VGA_HS), .VGA_CLK(VGA_CLK),
            .VGA_X(VGA_X), .VGA_Y(VGA_Y),
            .VGA_COLOUR(VGA_COLOUR), .VGA_PLOT(VGA_PLOT));

logic export_enable;

initial begin
    file = $fopen("..\\task4_syn_verilog.txt", "w");
    if (file == 0) begin
        $display("Failed to open file!");
    end
end

initial begin
    forever begin
        clk = 1'b0; #4;
        clk = 1'b1; #4;
        clk_counter = clk_counter + 1;
    end
end

always @(posedge clk)begin
    if (export_enable == 1'b1 && VGA_PLOT == 1'b1) 
        $fdisplay(file,"X=%3d, Y=%3d, color=%b", VGA_X, VGA_Y, VGA_COLOUR);
    if (VGA_X == 8'd0 && VGA_Y == 7'd0) begin
        finished <= finished << 1'b1;
    end
    else begin
        if (finished != 20'b1) finished <= finished >> 1'b1;
    end
end

initial begin
    
    // trial 1
    export_enable = 1'b1;
    KEY[3] = 1'b0; clk_counter = 0; #8; KEY[3] = 1'b1;

    #100;

    wait(finished == 20'b0); #2;
    $display("Finished! Clk used: %5d", clk_counter - 19);
    $fdisplay(file,"clk = %5d, ", clk_counter - 19);
    $fclose(file);
    $display("Running external Python script...");
    $system("python ..\\plot_modelsim_task4_syn.py 2 30 20 80");

    $stop;
end
endmodule

