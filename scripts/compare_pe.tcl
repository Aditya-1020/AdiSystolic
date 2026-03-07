set part "xc7a100tcsg324-1"  ;# CHANGE to your part (e.g., xc7a35ticsg324-1L)

# Multi-stage PE
read_verilog rtl/pe.sv
synth_design -top pe -part $part -directive RuntimeOptimized
report_utilization -file pe_util.rpt
report_timing_summary -max_paths 10 -file pe_timing.rpt
set_property is_blackbox true [get_cells pe]

# Simple PE
reset_run synth_1  ;# Clear previous
read_verilog rtl/simple_pe.sv
synth_design -top simple_pe -part $part -directive RuntimeOptimized
report_utilization -file simple_util.rpt
report_timing_summary -max_paths 10 -file simple_timing.rpt

puts "Comparison complete! Check *_util.rpt and *_timing.rpt"
puts "Example diff: diff pe_util.rpt simple_util.rpt"
