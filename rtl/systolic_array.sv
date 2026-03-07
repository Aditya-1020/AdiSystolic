// systolic_array: N * N grid
timeunit 1ns; timeprecision 1ps;

module systolic_array #(
    parameter DATA_WIDTH = 8,
    parameter ACCUM_WIDTH = 32,
    parameter N = 8
)(
    input logic i_clk,
    input logic i_rst_n,
    input logic signed [N-1:0][DATA_WIDTH-1:0] i_data,
    input logic signed [N-1:0][DATA_WIDTH-1:0] i_weight,
    output logic signed [N-1:0][N-1:0][ACCUM_WIDTH-1:0] o_result
);

    logic signed [N-1:0][N:0][DATA_WIDTH-1:0] data_w;
    logic signed [N:0][N-1:0][DATA_WIDTH-1:0] weight_w;

    genvar r, c;
    generate
        for (r = 0; r < N; r++) assign data_w[r][0]   = i_data[r];
        for (c = 0; c < N; c++) assign weight_w[0][c] = i_weight[c];
    endgenerate

    generate
        for (r = 0; r < N; r++) begin : row
            for (c = 0; c < N; c++) begin : col
                pe #(
                    .DATA_WIDTH(DATA_WIDTH),
                    .ACCUM_WIDTH(ACCUM_WIDTH)
                ) pe_inst (
                    .i_clk    (i_clk),
                    .i_rst_n  (i_rst_n),
                    .i_data   (data_w[r][c]),
                    .i_weight (weight_w[r][c]),
                    .o_data   (data_w[r][c+1]),
                    .o_weight (weight_w[r+1][c]),
                    .o_result (o_result[r][c])
                );
            end
        end
    endgenerate

endmodule