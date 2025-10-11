`define s1_f 1'b0 
`define s2_f 1'b1 


module onecolor_t4(input logic clk, input logic rst_n, input logic [2:0] colour,
                  input logic start, output logic finished,
                  output logic [7:0] vga_x, output logic [6:0] vga_y,
                  output logic [2:0] vga_colour, output logic vga_plot);
// fill the screen
logic count_enable;
logic done;
// logic finished


// a counter for y
always_ff @(posedge clk) begin   
     if (rst_n == 1'b0) vga_y <= 7'd0;
     else if(count_enable == 1'b1 && vga_y == 7'd119) vga_y <= 7'd0;
     else if(count_enable == 1'b1 && vga_y < 7'd119) vga_y <= vga_y + 7'd1;
     else vga_y <= vga_y;
end

// a counter for x
always_ff @(posedge clk) begin   
     if (rst_n == 1'b0) vga_x <= 8'd0;
     else if (vga_y == 7'd119 && count_enable == 1'b1 && vga_x == 8'd159) vga_x <= 8'd0;
     else if (vga_y == 7'd119 && count_enable == 1'b1) vga_x <= vga_x + 8'd1;
     else vga_x <= vga_x;
end

assign finished = (vga_x == 8'd159 && vga_y == 7'd119)? 1'b1: 1'b0;

// statemachine to do the task
logic pstate;
logic nstate;

// pstate logic 
always_ff@(posedge clk)begin
     if (rst_n == 1'b0) pstate <= `s1_f;
     else pstate <= nstate;
end

// nstate logic 
always_comb begin
     case (pstate)

     `s1_f: begin
          if(finished == 1'b1) nstate = `s2_f;
          else nstate = `s1_f; 
     end

     `s2_f: begin
          if(start == 1'b0) nstate = `s1_f;
          else nstate = `s2_f;
     end
     default: nstate = 2'bxx;
     endcase
end

// output logic 
always_comb begin
     case(pstate)
     `s1_f: begin
          {vga_colour, done} = {colour, 1'b0};
          vga_plot = start? 1'b1: 1'b0; 
          count_enable = start? 1'b1: 1'b0;
     end 
     `s2_f: {vga_colour, vga_plot, count_enable, done} = {3'b000, 1'b0, 1'b0, 1'b1}; 
     default: {vga_colour, vga_plot, count_enable, done} = {3'b000,1'b0, 1'b0, 1'b0};
     endcase
end
endmodule

