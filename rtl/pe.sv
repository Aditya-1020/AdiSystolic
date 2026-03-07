// Processing Element: performs A*B accumulation
timeunit 1ns; timeprecision 1ps;

module pe #(
    parameter DATA_WIDTH  = 8,
    parameter ACCUM_WIDTH = 32
)(
    input logic i_clk,
    input logic i_rst_n,
    input logic signed [DATA_WIDTH-1:0] i_data,
    input logic signed [DATA_WIDTH-1:0] i_weight,

    output logic signed [DATA_WIDTH-1:0] o_data,
    output logic signed [DATA_WIDTH-1:0] o_weight,
    output logic signed [ACCUM_WIDTH-1:0] o_result
);
    logic signed [DATA_WIDTH-1:0] data_r, weight_r;
    logic signed [2*DATA_WIDTH-1:0] mult_r;
    logic signed [ACCUM_WIDTH-1:0] accum;

    always_ff @(posedge i_clk) begin
        if (!i_rst_n) begin
            data_r   <= '0;
            weight_r <= '0;
            mult_r   <= '0;
            accum    <= '0;
            o_data   <= '0;
            o_weight <= '0;
        end else begin
            // Stage 1: latch + pass through
            data_r   <= i_data;
            weight_r <= i_weight;
            o_data   <= i_data;
            o_weight <= i_weight;

            // Stage 2: multiply
            mult_r <= data_r * weight_r;

            // Stage 3: always accumulate (stagger zeros cause no corruption)
            accum <= accum + ACCUM_WIDTH'(signed'(mult_r));
        end
    end

    assign o_result = accum;

endmodule