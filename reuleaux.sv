`define s0_t 3'b000      // reset state you need to load your parameters
`define s1_t 3'b001      // reset counter state the counter reset based on stored parameters
`define s2_t 3'b010      // clear state: start_clear = 1, the screen is cleared
`define s3_t 3'b011      // right state: start_right = 1, right is drawn
`define s4_t 3'b100      // left state: start_left = 1, left is drawn
`define s5_t 3'b101      // top state: start_top = 1, top is drawn
`define s6_t 3'b110      // done state: done = 1, if start = 0 goes to s0_t
`define sw 3

module reuleaux(input logic clk, input logic rst_n, input logic [2:0] colour,
                input logic [7:0] centre_x, input logic [6:0] centre_y, input logic [7:0] diameter,
                input logic start, output logic done,
                output logic [7:0] vga_x, output logic [6:0] vga_y,
                output logic [2:0] vga_colour, output logic vga_plot);

// reset signal for machines
logic rst_n_machines;

// signals for registers
logic [7:0] centre_x_str;
logic [7:0] centre_y_str;
logic [7:0] diameter_str;
logic load_all;

// a register that store the inputs
always_ff@(posedge clk)begin
     // if rst is low: reset
     if(rst_n == 1'b0)begin 
          centre_x_str <= 8'd0;
          centre_y_str <= 8'd0;
          diameter_str <= 8'd0;
     end

     // if reset is high and load is high: load
     else if(load_all == 1'b1)begin
          centre_x_str <= centre_x;
          centre_y_str <= {1'b0, centre_y};
          diameter_str <= diameter;
     end

     // else keep values
end

// caculate raduis and centers 
logic [7:0] centre_x_right; logic [7:0] centre_x_left; logic [7:0] centre_x_top;
logic [7:0] centre_y_right; logic [7:0] centre_y_left; logic [7:0] centre_y_top;
logic [31:0] temp; logic [6:0] diameter_half; logic left_ovf; logic top_ovf; 
assign diameter_half = diameter >> 1; 
assign temp = diameter_str * 151349;
always_comb begin
     centre_x_right = centre_x_str + diameter_half;
     centre_y_right = ((centre_y_str << 19) + temp) >> 19;
     
     left_ovf = (diameter_half > centre_x_str);
     centre_x_left = top_ovf? (centre_x_str << 1) - (diameter_half) << 1 + 1: centre_x_str - diameter_half;
     centre_y_left = ((centre_y_str << 19) + temp) >> 19;
     
     top_ovf = (temp > (centre_y_str << 18));
     centre_x_top = centre_x_str;
     centre_y_top = top_ovf? (((centre_y_str << 18) - temp + (1 << 17)) >> 18): ((centre_y_str << 18) - temp) >> 18; 
end

// caculate x,y range
logic [7:0] x_min_right; logic [7:0] x_max_right; logic [7:0] y_min_right; logic [7:0] y_max_right;
logic [7:0] x_min_left; logic [7:0] x_max_left; logic [7:0] y_min_left; logic [7:0] y_max_left;
logic [7:0] x_min_top; logic [7:0] x_max_top; logic [7:0] y_min_top; logic [7:0] y_max_top;

always_comb begin
     x_min_right = left_ovf? 8'd0: centre_x_left;
     x_max_right = centre_x_top;
     y_min_right = top_ovf? 8'd0: centre_y_top;
     y_max_right = centre_y_left;

     x_min_left = centre_x_top;
     x_max_left = centre_x_right;
     y_min_left = top_ovf? 8'd0: centre_y_top;
     y_max_left = centre_y_right;

     x_min_top = left_ovf? 8'd0: centre_x_left;
     x_max_top = centre_x_right;
     y_min_top = centre_y_right;
     y_max_top = centre_y_top + diameter_str;
end

// signals for onecolor
logic finished_clear;
logic start_clear;
logic [7:0] vga_x_clear;
logic [6:0] vga_y_clear;
logic [2:0] vga_colour_clear;
logic vga_plot_clear;

onecolor_t4 clear(.clk(clk), .rst_n(rst_n_machines), .colour(3'b000),
               .start(start_clear), .finished(finished_clear), 
               .vga_x(vga_x_clear), .vga_y(vga_y_clear), .vga_colour(vga_colour_clear), 
               .vga_plot(vga_plot_clear));

// signals for right circle
logic finished_right;
logic start_right;
logic [7:0] vga_x_right;
logic [6:0] vga_y_right;
logic [2:0] vga_colour_right;
logic vga_plot_right;

circle_t4_right circle_right(.clk(clk), .rst_n(rst_n_machines), .colour(colour),
              .centre_x(centre_x_right), .centre_y(centre_y_right), .radius(diameter_str),
              .start(start_right), .finished(finished_right),
              .vga_x(vga_x_right), .vga_y(vga_y_right),
              .vga_colour(vga_colour_right), .vga_plot(vga_plot_right));

// signals for left circle
logic finished_left;
logic start_left;
logic [7:0] vga_x_left;
logic [6:0] vga_y_left;
logic [2:0] vga_colour_left;
logic vga_plot_left;

circle_t4_left circle_left(.clk(clk), .rst_n(rst_n_machines), .colour(colour),
              .centre_x(centre_x_left), .centre_y(centre_y_left), .radius(diameter_str),
              .start(start_left), .finished(finished_left),
              .vga_x(vga_x_left), .vga_y(vga_y_left),
              .vga_colour(vga_colour_left), .vga_plot(vga_plot_left));

// signals for top circle
logic finished_top;
logic start_top;
logic [7:0] vga_x_top;
logic [6:0] vga_y_top;
logic [2:0] vga_colour_top;
logic vga_plot_top;

circle_t4_top circle_top(.clk(clk), .rst_n(rst_n_machines), .colour(colour),
              .centre_x(centre_x_top), .centre_y(centre_y_top), .radius(diameter_str),
              .start(start_top), .finished(finished_top),
              .vga_x(vga_x_top), .vga_y(vga_y_top),
              .vga_colour(vga_colour_top), .vga_plot(vga_plot_top));

// vga_x, vga_y, vga_colour MUX
logic clear_sel, right_sel, left_sel, top_sel;
always_comb begin
     
     if({clear_sel, right_sel, left_sel, top_sel} == 4'b1000)begin
          vga_x = vga_x_clear;
          vga_y = vga_y_clear;
          vga_colour = vga_colour_clear;
     end
     else if({clear_sel, right_sel, left_sel, top_sel} == 4'b0100)begin
          vga_x = vga_x_right;
          vga_y = vga_y_right;
          vga_colour = vga_colour_right;
     end
     else if({clear_sel, right_sel, left_sel, top_sel} == 4'b0010)begin
          vga_x = vga_x_left;
          vga_y = vga_y_left;
          vga_colour = vga_colour_left;
     end
     else if({clear_sel, right_sel, left_sel, top_sel} == 4'b0001)begin
          vga_x = vga_x_top;
          vga_y = vga_y_top;
          vga_colour = vga_colour_top;
     end
     else begin
          vga_x = 8'bx;
          vga_y = 7'bx;
          vga_colour = 3'bx;
     end
end

// vga_plot MUX
always_comb begin
     
     if({clear_sel, right_sel, left_sel, top_sel} == 4'b1000)begin
          vga_plot = (vga_plot_clear==1'b1)? 1'b1: 1'b0;
     end
     else if({clear_sel, right_sel, left_sel, top_sel} == 4'b0100)begin
          vga_plot = (
          vga_x_right >= x_min_right && vga_x_right <= x_max_right &&
          vga_y_right >= y_min_right && vga_y_right <= y_max_right)? 1'b1: 1'b0;
     end
     else if({clear_sel, right_sel, left_sel, top_sel} == 4'b0010)begin
          vga_plot = (
          vga_x_left >= x_min_left && vga_x_left <= x_max_left &&
          vga_y_left >= y_min_left && vga_y_left <= y_max_left)? 1'b1: 1'b0;
     end
     else if({clear_sel, right_sel, left_sel, top_sel} == 4'b0001)begin
          vga_plot = (
          vga_x_top >= x_min_top && vga_x_top <= x_max_top &&
          vga_y_top >= y_min_top && vga_y_top <= y_max_top)? 1'b1: 1'b0;
     end
     else begin
          vga_plot = 1'bx;
     end
end

// statemachine that controls the four blocks
// control signals(outputs):
// rst_n_machines, 
// start_clear, start_right, start_left, start_top, 
// clear_sel, right_sel, left_sel, top_sel
// 
logic [`sw-1:0] pstate;
logic [`sw-1:0] nstate;

// pstate logic
always_ff@(posedge clk)begin
     if(rst_n == 1'b0) pstate <= `s0_t;
     else pstate <= nstate;
end

// nstate logic
always_comb begin
     case(pstate)
     `s0_t: begin
          if(start == 1'b1) nstate = `s1_t;
          else nstate = `s0_t;
     end
     `s1_t: begin
          if(start == 1'b1) nstate = `s2_t;
          else nstate = `s1_t;
     end
     `s2_t: begin
          if(start == 1'b1 && finished_clear == 1'b1) nstate = `s3_t;
          else nstate = `s2_t;
     end
     `s3_t: begin
          if(start == 1'b1 && finished_right == 1'b1) nstate = `s4_t;
          else nstate = `s3_t;
     end
     `s4_t: begin
          if(start == 1'b1 && finished_left == 1'b1) nstate = `s5_t;
          else nstate = `s4_t;
     end
     `s5_t: begin
          if(start == 1'b1 && finished_top == 1'b1) nstate = `s6_t;
          else nstate = `s5_t;
     end
     `s6_t: begin
          if(start == 1'b0) nstate = `s0_t;
          else nstate = `s6_t;
     end
     default: nstate = 3'bx;
     endcase
end

// output logic
always_comb begin
     case(pstate)
     `s0_t: begin
          load_all = 1'b1; rst_n_machines = 1'b1; 
          start_clear = 1'b0; start_right = 1'b0; start_left = 1'b0; start_top = 1'b0; 
          clear_sel = 1'b0; right_sel = 1'b0; left_sel = 1'b0; top_sel = 1'b0;
          done = 1'b0;
     end
     `s1_t: begin
          load_all = 1'b0; rst_n_machines = 1'b0; 
          start_clear = 1'b0; start_right = 1'b0; start_left = 1'b0; start_top = 1'b0; 
          clear_sel = 1'b0; right_sel = 1'b0; left_sel = 1'b0; top_sel = 1'b0;
          done = 1'b0;
     end
     `s2_t: begin
          load_all = 1'b0; rst_n_machines = 1'b1; 
          start_clear = 1'b1; start_right = 1'b0; start_left = 1'b0; start_top = 1'b0; 
          clear_sel = 1'b1; right_sel = 1'b0; left_sel = 1'b0; top_sel = 1'b0;
          done = 1'b0;
     end
     `s3_t: begin
          load_all = 1'b0; rst_n_machines = 1'b1; 
          start_clear = 1'b1; start_right = 1'b1; start_left = 1'b0; start_top = 1'b0; 
          clear_sel = 1'b0; right_sel = 1'b1; left_sel = 1'b0; top_sel = 1'b0;
          done = 1'b0;
     end
     `s4_t: begin
          load_all = 1'b0; rst_n_machines = 1'b1; 
          start_clear = 1'b1; start_right = 1'b1; start_left = 1'b1; start_top = 1'b0; 
          clear_sel = 1'b0; right_sel = 1'b0; left_sel = 1'b1; top_sel = 1'b0;
          done = 1'b0;
     end
     `s5_t: begin
          load_all = 1'b0; rst_n_machines = 1'b1; 
          start_clear = 1'b1; start_right = 1'b1; start_left = 1'b1; start_top = 1'b1; 
          clear_sel = 1'b0; right_sel = 1'b0; left_sel = 1'b0; top_sel = 1'b1;
          done = 1'b0;
     end
     `s6_t: begin
          load_all = 1'b0; rst_n_machines = 1'b0; 
          start_clear = 1'b0; start_right = 1'b0; start_left = 1'b0; start_top = 1'b0; 
          clear_sel = 1'b0; right_sel = 1'b0; left_sel = 1'b0; top_sel = 1'b0;
          done = 1'b1;
     end
     default: begin
          load_all = 1'bx; rst_n_machines = 1'bx; 
          start_clear = 1'bx; start_right = 1'bx; start_left = 1'bx; start_top = 1'bx; 
          clear_sel = 1'bx; right_sel = 1'bx; left_sel = 1'bx; top_sel = 1'bx;
          done = 1'bx;
     end
     endcase
end
endmodule

