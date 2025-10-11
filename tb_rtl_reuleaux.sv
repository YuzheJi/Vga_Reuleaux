`timescale 1ps/1ps
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
    if (DUT.clear.done == 1'b1 && vga_plot == 1'b1) $fdisplay(file,"X=%3d, Y=%3d, state: %b", vga_x, vga_y, DUT.pstate);
end

initial begin
    
    // initialize
    // trial 1
    rst_n = 1'b0; start = 1'b0; #4; rst_n = 1'b1;
    colour = 3'b010; centre_x = 8'd10; centre_y = 7'd40; diameter = 8'd70;
    start = 1'b1; clk_counter = 0;

    wait(DUT.finished_clear == 1'b1); #2;
    $info("Trial 1: Screen Cleared! Clock cycle used: %0d", clk_counter);

    wait(DUT.finished_right == 1'b1); #2;
    $info("Trial 1: Right Done! Clock cycle used: %0d", clk_counter);

    wait(DUT.finished_left == 1'b1); #2;
    $info("Trial 1: Left Done! Clock cycle used: %0d", clk_counter);

    wait(DUT.finished_top == 1'b1); #2;
    $info("Trial 1: Top Done! Clock cycle used: %0d", clk_counter);

    wait(done == 1'b1); #2;
    $info("Trial 1: All Done! Clock cycle used: %0d", clk_counter);
    $fdisplay(file,"clk = %d, ", clk_counter);

    #10;
    start = 1'b0;
    #20;
    $fclose(file);
    $display("Running external Python script...");
    $system("python ..\\plot_modelsim.py 10 40 70");
    $stop;
end
endmodule
