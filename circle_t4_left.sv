`define s21_c 4'b0000 
`define s22_c 4'b0001  
`define s23_c 4'b0010  
`define s24_c 4'b0011 
`define s25_c 4'b0100 
`define s26_c 4'b0101 
`define s27_c 4'b0110 
`define s28_c 4'b0111 
`define s3_c  4'b1010

module circle_t4_left(input logic clk, input logic rst_n, input logic [2:0] colour,
              input logic [7:0] centre_x, input logic [7:0] centre_y, input logic [7:0] radius,
              input logic start, output logic finished,
              output logic [7:0] vga_x, output logic [6:0] vga_y,
              output logic [2:0] vga_colour, output logic vga_plot);
// draw the circle

assign vga_colour = colour;
// inputs for counter
logic [7:0] offset_x;
logic [7:0] offset_y;
logic [8:0] crit;
logic count_enable;
logic rst_n_counter;
logic done;
// logic finished

always_ff@(posedge clk) begin
     if (rst_n_counter == 1'b0 || rst_n == 1'b0)begin
          offset_y <= 8'b0;
          offset_x <= radius;
          crit <= 1 - radius;
     end
     else if(count_enable == 1'b1) begin
          offset_y <= offset_y + 1;
          if(crit[8] == 1'b1 || crit == 8'b0) begin
               crit <= crit + 2 * offset_y + 2 + 1;
          end
          else begin
               offset_x <= offset_x - 1;
               crit <= crit + 2*(offset_y - offset_x + 2) + 1;
          end
     end    
end

// finished logic 
assign finished = (offset_y <= offset_x)? 1'b0: 1'b1;

// state machine that: controls the counter, out put to vga
logic [3:0] pstate;
logic [3:0] nstate;

// pstate logic 
always_ff@(posedge clk) begin
     if (rst_n == 1'b0) pstate <= `s21_c;
     else pstate <= nstate;
end

// nstate logic 
always_comb begin 
     
     case(pstate)
     `s21_c: begin
          if(finished == 1'b1) nstate = `s3_c;
          else if ({start, finished} == 2'b10) nstate = `s22_c;
          else nstate = `s21_c;
     end
     `s22_c: begin
          if ({start, finished} == 2'b10) nstate = `s27_c;
          else nstate = `s22_c;
     end
     `s27_c: begin
          if ({start, finished} == 2'b10) nstate = `s28_c;
          else nstate = `s27_c;
     end
     `s28_c: begin
          if ({start, finished} == 2'b10) nstate = `s21_c;
          else nstate = `s28_c;
     end
     `s3_c: begin
          if(start == 1'b0) nstate = `s21_c;
          else nstate = `s3_c;
     end
     default: nstate = 4'bx;
     endcase
end

// output logic 
always_comb begin
     
     case(pstate)
     `s21_c: begin
          count_enable = 1'b0; done = 1'b0;
          vga_x = centre_x + offset_x; 
          vga_y = centre_y + offset_y; 
          if (finished == 1'b1 || start == 1'b0) vga_plot = 1'b0;
          else if (centre_x + offset_x > 159 || centre_y + offset_y >119) vga_plot = 1'b0;
          else vga_plot = 1'b1;
          if(finished == 1'b1) rst_n_counter = 1'b0;
          else rst_n_counter = 1'b1;
     end
     `s22_c: begin
          count_enable = 1'b0; rst_n_counter = 1'b1; done = 1'b0;
          vga_x = centre_x + offset_y; 
          vga_y = centre_y + offset_x; 
          if (centre_x + offset_y > 159 || centre_y + offset_x >119) vga_plot = 1'b0;
          else vga_plot = 1'b1;
     end
     `s27_c: begin
          count_enable = 1'b0; rst_n_counter = 1'b1; done = 1'b0;
          vga_x = centre_x + offset_x; 
          vga_y = centre_y - offset_y; 
          if (centre_x + offset_x > 159 || offset_y > centre_y) vga_plot = 1'b0;
          else vga_plot = 1'b1;
     end
     `s28_c: begin
          count_enable = 1'b1; rst_n_counter = 1'b1; done = 1'b0;
          vga_x = centre_x + offset_y; 
          vga_y = centre_y - offset_x; 
          if (centre_x + offset_y > 159 || offset_x > centre_y) vga_plot = 1'b0;
          else vga_plot = 1'b1;
     end
     `s3_c: begin
          count_enable = 1'b0; vga_plot = 1'b0; rst_n_counter = 1'b1;
          done = 1'b1;
          vga_x = 8'bx; 
          vga_y = 7'bx; 
     end
     default: begin
          count_enable = 1'b0; vga_plot = 1'b0; rst_n_counter = 1'b1;
          done = 1'b0;
          vga_x = 8'bx; 
          vga_y = 7'bx;
     end
     endcase
end
endmodule

