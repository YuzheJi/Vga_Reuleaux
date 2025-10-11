onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /tb_rtl_reuleaux/centre_x
add wave -noupdate -radix unsigned /tb_rtl_reuleaux/centre_y
add wave -noupdate -radix unsigned /tb_rtl_reuleaux/diameter
add wave -noupdate /tb_rtl_reuleaux/DUT/centre_x_str
add wave -noupdate /tb_rtl_reuleaux/DUT/centre_y_str
add wave -noupdate /tb_rtl_reuleaux/DUT/diameter_str
add wave -noupdate /tb_rtl_reuleaux/clk
add wave -noupdate /tb_rtl_reuleaux/rst_n
add wave -noupdate /tb_rtl_reuleaux/start
add wave -noupdate -label Pstate(Reu) /tb_rtl_reuleaux/DUT/pstate
add wave -noupdate -label Pstate(Clr) /tb_rtl_reuleaux/DUT/clear/pstate
add wave -noupdate -label Pstate(R) /tb_rtl_reuleaux/DUT/circle_right/pstate
add wave -noupdate -label Pstate(L) /tb_rtl_reuleaux/DUT/circle_left/pstate
add wave -noupdate -label Pstate(T) /tb_rtl_reuleaux/DUT/circle_top/pstate
add wave -noupdate /tb_rtl_reuleaux/DUT/finished_clear
add wave -noupdate /tb_rtl_reuleaux/DUT/finished_left
add wave -noupdate /tb_rtl_reuleaux/DUT/finished_right
add wave -noupdate /tb_rtl_reuleaux/DUT/finished_top
add wave -noupdate /tb_rtl_reuleaux/vga_colour
add wave -noupdate /tb_rtl_reuleaux/vga_plot
add wave -noupdate -radix unsigned /tb_rtl_reuleaux/vga_x
add wave -noupdate -radix unsigned /tb_rtl_reuleaux/vga_y
add wave -noupdate -expand -group R -label start(R) /tb_rtl_reuleaux/DUT/circle_right/start
add wave -noupdate -expand -group R -label plot(R) /tb_rtl_reuleaux/DUT/vga_plot_right
add wave -noupdate -expand -group R -label vga_x(R) -radix unsigned /tb_rtl_reuleaux/DUT/vga_x_right
add wave -noupdate -expand -group R -label vga_y(R) -radix unsigned /tb_rtl_reuleaux/DUT/vga_y_right
add wave -noupdate -expand -group R -radix unsigned /tb_rtl_reuleaux/DUT/centre_x_right
add wave -noupdate -expand -group R -radix unsigned /tb_rtl_reuleaux/DUT/centre_y_right
add wave -noupdate -expand -group R -radix unsigned /tb_rtl_reuleaux/DUT/x_max_right
add wave -noupdate -expand -group R -radix unsigned /tb_rtl_reuleaux/DUT/x_min_right
add wave -noupdate -expand -group R -radix unsigned /tb_rtl_reuleaux/DUT/y_max_right
add wave -noupdate -expand -group R -radix unsigned /tb_rtl_reuleaux/DUT/y_min_right
add wave -noupdate -expand -group R -label OFF_X(R) /tb_rtl_reuleaux/DUT/circle_right/offset_x
add wave -noupdate -expand -group R -label OFF_Y(R) /tb_rtl_reuleaux/DUT/circle_right/offset_y
add wave -noupdate -expand -group OFF(L) -label start(L) /tb_rtl_reuleaux/DUT/circle_left/start
add wave -noupdate -expand -group OFF(L) -label plot(L) /tb_rtl_reuleaux/DUT/vga_plot_left
add wave -noupdate -expand -group OFF(L) -label vga_x(L) -radix unsigned /tb_rtl_reuleaux/DUT/vga_x_left
add wave -noupdate -expand -group OFF(L) -label vga_y(L) -radix unsigned /tb_rtl_reuleaux/DUT/vga_y_left
add wave -noupdate -expand -group OFF(L) -radix unsigned /tb_rtl_reuleaux/DUT/centre_x_left
add wave -noupdate -expand -group OFF(L) -radix unsigned /tb_rtl_reuleaux/DUT/centre_y_left
add wave -noupdate -expand -group OFF(L) -radix unsigned /tb_rtl_reuleaux/DUT/x_max_left
add wave -noupdate -expand -group OFF(L) -radix unsigned /tb_rtl_reuleaux/DUT/x_min_left
add wave -noupdate -expand -group OFF(L) -radix unsigned /tb_rtl_reuleaux/DUT/y_max_left
add wave -noupdate -expand -group OFF(L) -radix unsigned /tb_rtl_reuleaux/DUT/y_min_left
add wave -noupdate -expand -group OFF(L) -label OFF_X(L) /tb_rtl_reuleaux/DUT/circle_left/offset_x
add wave -noupdate -expand -group OFF(L) -label OFF_Y(L) /tb_rtl_reuleaux/DUT/circle_left/offset_y
add wave -noupdate -expand -group OFF(T) -label start(T) /tb_rtl_reuleaux/DUT/circle_top/start
add wave -noupdate -expand -group OFF(T) -label plot(T) /tb_rtl_reuleaux/DUT/vga_plot_top
add wave -noupdate -expand -group OFF(T) -label vga_x(T) -radix unsigned /tb_rtl_reuleaux/DUT/vga_x_top
add wave -noupdate -expand -group OFF(T) -label vga_y(T) -radix unsigned /tb_rtl_reuleaux/DUT/vga_y_top
add wave -noupdate -expand -group OFF(T) -radix unsigned /tb_rtl_reuleaux/DUT/centre_x_top
add wave -noupdate -expand -group OFF(T) -radix unsigned /tb_rtl_reuleaux/DUT/centre_y_top
add wave -noupdate -expand -group OFF(T) -radix unsigned /tb_rtl_reuleaux/DUT/x_max_top
add wave -noupdate -expand -group OFF(T) -radix unsigned /tb_rtl_reuleaux/DUT/x_min_top
add wave -noupdate -expand -group OFF(T) -radix unsigned /tb_rtl_reuleaux/DUT/y_max_top
add wave -noupdate -expand -group OFF(T) -radix unsigned /tb_rtl_reuleaux/DUT/y_min_top
add wave -noupdate -expand -group OFF(T) -label OFF_X(T) /tb_rtl_reuleaux/DUT/circle_top/offset_x
add wave -noupdate -expand -group OFF(T) -label OFF_Y(T) /tb_rtl_reuleaux/DUT/circle_top/offset_y
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {79583 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 257
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {79581 ps} {79642 ps}
