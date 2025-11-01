`timescale 1ps/1ps
`define s0_t 3'b000      // reset state you need to load your parameters
`define s1_t 3'b001      // reset counter state the counter reset based on stored parameters
`define s2_t 3'b010      // clear state: start_clear = 1, the screen is cleared
`define s3_t 3'b011      // right state: start_right = 1, right is drawn
`define s4_t 3'b100      // left state: start_left = 1, left is drawn
`define s5_t 3'b101      // top state: start_top = 1, top is drawn
`define s6_t 3'b110      // done state: done = 1, if start = 0 goes to s0_t

module tb_rtl_reuleaux();

integer file;
logic clk, rst_n, start, done;
logic [2:0] colour;
logic [7:0] centre_x;
logic [6:0] centre_y;
logic [7:0] diameter;
logic [7:0] vga_x;
logic [6:0] vga_y;
logic [2:0] vga_colour;
logic vga_plot;

reuleaux DUT (.clk(clk), .rst_n(rst_n), .colour(colour),
               .centre_x(centre_x), .centre_y(centre_y), .diameter(diameter),
               .start(start), .done(done),
               .vga_x(vga_x), .vga_y(vga_y),
               .vga_colour(vga_colour), .vga_plot(vga_plot));

logic [14:0] clk_counter;
logic export_enable;

initial begin
    file = $fopen("..\\reuleaux_verilog.txt", "w");
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
    if (export_enable == 1'b1 && DUT.clear.done == 1'b1 && vga_plot == 1'b1) $fdisplay(file,"X=%3d, Y=%3d, state: %b", vga_x, vga_y, DUT.pstate);
end

initial begin
    
    // trial1
    #4; export_enable = 1'b0;
    rst_n = 1'b0; start = 1'b0; #4; rst_n = 1'b1;
    assert(DUT.pstate == `s0_t)
        else begin 
            $error("The present state should be s0_t, reset state");
        end
    colour = 3'b010; centre_x = 8'd30; centre_y = 7'd120; diameter = 8'd70;
    start = 1'b1; clk_counter = 0;

    #4;
    assert(DUT.pstate == `s1_t)
        else begin 
            $error("The present state should be s1_t, loaded state");
        end
    rst_n = 1'b0; start = 1'b0; #4; rst_n = 1'b1;
    assert(DUT.pstate == `s0_t)
        else begin 
            $error("The present state should be s0_t, reset state");
        end
    start = 1'b1; clk_counter = 0;

    #8;
    assert(DUT.pstate == `s2_t)
        else begin 
            $error("The present state should be s2_t, clearing state");
        end
    rst_n = 1'b0; start = 1'b0; #4; rst_n = 1'b1;
    assert(DUT.pstate == `s0_t)
        else begin 
            $error("The present state should be s0_t, reset state");
        end
    start = 1'b1; clk_counter = 0;

    wait(DUT.finished_clear == 1'b1); #2;
    $info("Trial 1: Screen Cleared!");
    #4;
    assert(DUT.pstate == `s3_t)
        else begin 
            $error("The present state should be s3_t, right state");
        end
    rst_n = 1'b0; start = 1'b0; #4; rst_n = 1'b1;
    assert(DUT.pstate == `s0_t)
        else begin 
            $error("The present state should be s0_t, reset state");
        end
    start = 1'b1; clk_counter = 0;

    wait(DUT.finished_right == 1'b1); #2;
    $info("Trial 1: Right Done!");
    #4;
    assert(DUT.pstate == `s4_t)
        else begin 
            $error("The present state should be s4_t, left state");
        end
    rst_n = 1'b0; start = 1'b0; #4; rst_n = 1'b1;
    assert(DUT.pstate == `s0_t)
        else begin 
            $error("The present state should be s0_t, reset state");
        end
    start = 1'b1; clk_counter = 0;

    wait(DUT.finished_left == 1'b1); #2;
    $info("Trial 1: Left Done!");
    #4;
    assert(DUT.pstate == `s5_t)
        else begin 
            $error("The present state should be s5_t, right state");
        end
    rst_n = 1'b0; start = 1'b0; #4; rst_n = 1'b1;
    assert(DUT.pstate == `s0_t)
        else begin 
            $error("The present state should be s0_t, reset state");
        end
    start = 1'b1; clk_counter = 0;

    wait(DUT.finished_top == 1'b1); #2;
    $info("Trial 1: Top Done!");
    #4; 
    assert(DUT.pstate == `s6_t)
        else begin 
            $error("The present state should be s6_t, done state");
        end
    rst_n = 1'b0; start = 1'b0; #4; rst_n = 1'b1;
    assert(DUT.pstate == `s0_t)
        else begin 
            $error("The present state should be s0_t, reset state");
        end
    start = 1'b1; clk_counter = 0;

    wait(done == 1'b1); #2;
    $info("Trial 1: All Done!");
    rst_n = 1'b0; start = 1'b0; #4; rst_n = 1'b1;
    assert(DUT.pstate == `s0_t)
        else begin 
            $error("The present state should be s0_t, reset state");
        end
    start = 1'b1; clk_counter = 0;
    #10;
    start = 1'b0;
    #20;

    // trial 2
    #6; export_enable = 1'b1;
    rst_n = 1'b0; start = 1'b0; #4; rst_n = 1'b1;
    assert(DUT.pstate == `s0_t)
        else begin 
            $error("The present state should be s0_t, reset state");
        end
    colour = 3'b010; centre_x = 8'd30; centre_y = 7'd20; diameter = 8'd80;
    start = 1'b1; clk_counter = 0;

    #4;
    assert(DUT.pstate == `s1_t)
        else begin 
            $error("The present state should be s1_t, loaded state");
        end

    #4;
    assert(DUT.pstate == `s2_t)
        else begin 
            $error("The present state should be s2_t, clearing state");
        end

    wait(DUT.finished_clear == 1'b1); #2;
    $info("Trial 2: Screen Cleared! Clock cycle used: %0d", clk_counter);
    #4;
    assert(DUT.pstate == `s3_t)
        else begin 
            $error("The present state should be s3_t, right state");
        end

    wait(DUT.finished_right == 1'b1); #2;
    $info("Trial 2: Right Done! Clock cycle used: %0d", clk_counter);
    #4;
    assert(DUT.pstate == `s4_t)
        else begin 
            $error("The present state should be s4_t, left state");
        end

    wait(DUT.finished_left == 1'b1); #2;
    $info("Trial 2: Left Done! Clock cycle used: %0d", clk_counter);
    #4;
    assert(DUT.pstate == `s5_t)
        else begin 
            $error("The present state should be s5_t, right state");
        end

    wait(DUT.finished_top == 1'b1); #2;
    $info("Trial 2: Top Done! Clock cycle used: %0d", clk_counter);
    #4; 
    assert(DUT.pstate == `s6_t)
        else begin 
            $error("The present state should be s6_t, done state");
        end

    wait(done == 1'b1); #2;
    $info("Trial 2: All Done! Clock cycle used: %0d", clk_counter);
    $fdisplay(file,"clk = %d, ", clk_counter);

    #10;
    start = 1'b0;
    #20;
    $fclose(file);
    $display("Running external Python script...");
    $system("python ..\\plot_modelsim.py 30 20 80");

    $stop;
end
endmodule
