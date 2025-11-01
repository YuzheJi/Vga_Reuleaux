`timescale 1ps/1ps
`define s0_t 3'b000      // reset state you need to load your parameters
`define s1_t 3'b001      // reset counter state the counter reset based on stored parameters
`define s2_t 3'b010      // clear state: start_clear = 1, the screen is cleared
`define s3_t 3'b011      // right state: start_right = 1, right is drawn
`define s4_t 3'b100      // left state: start_left = 1, left is drawn
`define s5_t 3'b101      // top state: start_top = 1, top is drawn
`define s6_t 3'b110      // done state: done = 1, if start = 0 goes to s0_t
module tb_rtl_task4();

integer file;
logic clk;
logic err;

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

logic [14:0] clk_counter;
logic export_enable;

initial begin
    file = $fopen("..\\task4_verilog.txt", "w");
    if (file == 0) begin
        $display("Failed to open file!");
    end
end

initial begin
    forever begin
        clk = 1'b0; #2;
        clk = 1'b1; #2;
        clk_counter = clk_counter + 1;
    end
end

always @(posedge clk)begin
    if (export_enable == 1'b1 && DUT.reuleaux.clear.done == 1'b1 && VGA_PLOT == 1'b1) 
        $fdisplay(file,"X=%3d, Y=%3d, state: %b", VGA_X, VGA_Y, DUT.reuleaux.pstate);
end

initial begin
    
    // trial 1
    err = 1'b0; #6; export_enable = 1'b1;
    KEY[3] = 1'b0; #4; KEY[3] = 1'b1;
    assert(DUT.reuleaux.pstate == `s0_t)
        else begin 
            $error("The present state should be s0_t, reset state");
            err = 1'b1;
        end
    clk_counter = 0;

    #4;
    assert(DUT.reuleaux.pstate == `s1_t)
        else begin 
            $error("The present state should be s1_t, loaded state");
            err = 1'b1;
        end

    #4;
    assert(DUT.reuleaux.pstate == `s2_t)
        else begin 
            $error("The present state should be s2_t, clearing state");
            err = 1'b1;
        end

    wait(DUT.reuleaux.finished_clear == 1'b1); #2;
    $info("Trial 1: Screen Cleared! Clock cycle used: %0d", clk_counter);
    #4;
    assert(DUT.reuleaux.pstate == `s3_t)
        else begin 
            $error("The present state should be s3_t, right state");
            err = 1'b1;
        end

    wait(DUT.reuleaux.finished_right == 1'b1); #2;
    $info("Trial 1: Right Done! Clock cycle used: %0d", clk_counter);
    #4;
    assert(DUT.reuleaux.pstate == `s4_t)
        else begin 
            $error("The present state should be s4_t, left state");
            err = 1'b1;
        end

    wait(DUT.reuleaux.finished_left == 1'b1); #2;
    $info("Trial 1: Left Done! Clock cycle used: %0d", clk_counter);
    #4;
    assert(DUT.reuleaux.pstate == `s5_t)
        else begin 
            $error("The present state should be s5_t, right state");
            err = 1'b1;
        end

    wait(DUT.reuleaux.finished_top == 1'b1); #2;
    $info("Trial 1: Top Done! Clock cycle used: %0d", clk_counter);
    #4; 
    assert(DUT.reuleaux.pstate == `s6_t)
        else begin 
            $error("The present state should be s6_t, done state");
            err = 1'b1;
        end

    wait(DUT.reuleaux.done == 1'b1); #2;
    $info("Trial 1: All Done! Clock cycle used: %0d", clk_counter);
    $fdisplay(file,"clk = %d, ", clk_counter);

    #20;
    $fclose(file);
    if(err == 1'b0) $display("State Check Passes!");
    else $display("State Check Fails...");
    $display("Running external Python script...");
    $system("python ..\\plot_modelsim_task4.py 30 20 80");

    $stop;
end
endmodule
