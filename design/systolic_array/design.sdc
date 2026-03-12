create_clock -name i_clk -period 20.0 [get_ports i_clk]

set_input_delay  -clock i_clk 2.0 [get_ports {i_rst_n i_start wr_en_a wr_en_b wr_addr wr_data rd_row rd_col}]
set_output_delay -clock i_clk 2.0 [all_outputs]

set_false_path -from [get_ports i_rst_n]
set_clock_uncertainty 0.5 [get_clocks i_clk]

set_propagated_clock [get_clocks i_clk]
