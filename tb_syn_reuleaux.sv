`timescale 1ps/1ps
module tb_syn_reuleaux();

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
logic [14:0] clk_counter;

logic [19:0] finished;

reuleaux DUT (.clk(clk), .rst_n(rst_n), .colour(colour),
               .centre_x(centre_x), .centre_y(centre_y), .diameter(diameter),
               .start(start), .done(done),
               .vga_x(vga_x), .vga_y(vga_y),
               .vga_colour(vga_colour), .vga_plot(vga_plot));

logic export_enable;

initial begin
    file = $fopen("..\\reuleaux_syn_verilog.txt", "w");
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
    if (export_enable == 1'b1 && vga_plot == 1'b1) $fdisplay(file,"X=%3d, Y=%3d, color=%b", vga_x, vga_y, vga_colour);
    if (vga_x == 8'd0 && vga_y == 7'd0) begin
        finished <= finished << 1'b1;
    end
    else begin
        if (finished != 20'b1) finished <= finished >> 1'b1;
    end
end

initial begin
    
    // trial 1
    export_enable = 1'b1; finished = 20'b1;
    rst_n = 1'b0; start = 1'b0; #4; rst_n = 1'b1;
    colour = 3'b010; centre_x = 8'd30; centre_y = 7'd20; diameter = 8'd80;
    start = 1'b1; clk_counter = 0;

    #100;

    wait(finished == 20'b0); #2;
    $display("Finished! Clk used: %5d", clk_counter - 19);
    $fdisplay(file,"clk = %d, ", clk_counter - 19);
    $fclose(file);
    $display("Running external Python script...");
    $system("python ..\\plot_modelsim_reuleaux_syn.py 2 30 20 80");

    $stop;
end
endmodule

