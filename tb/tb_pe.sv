timeunit 1ns; timeprecision 1ps;

module tb_pe;

    parameter DATA_WIDTH = 8;
    parameter ACCUM_WIDTH = 32;

    logic clk, rst_n;
    logic signed [DATA_WIDTH-1:0] data_in, data_out;
    logic signed [DATA_WIDTH-1:0] weight_in, weight_out;
    logic signed [ACCUM_WIDTH-1:0] psum_in, psum_out;

    pe #(
        .DATA_WIDTH(DATA_WIDTH),
        .ACCUM_WIDTH(ACCUM_WIDTH)
    ) dut (
        .i_clk(clk),
        .rst_n(rst_n),
        .i_data(data_in),
        .i_weight(weight_in),
        .i_psum(psum_in),
        .o_data(data_out),
        .o_weight(weight_out),
        .o_psum(psum_out)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    task reset_dut;
        rst_n = 0;
        repeat(2) @(posedge clk);
        rst_n = 1;
        @(posedge clk); #1;
    endtask

    logic signed [2*ACCUM_WIDTH-1:0] expected_mult, mult_temp;
    logic signed [ACCUM_WIDTH-1:0] expected_mac;

   task test_mult(
        input signed [DATA_WIDTH-1:0] din,
        input signed [DATA_WIDTH-1:0] win
    );
        data_in = din;
        weight_in = win;
        psum_in = 0;
        repeat(3) @(posedge clk);
        
        expected_mult = $signed(din) * $signed(win);
        
        assert (dut.mult_r == expected_mult)
            else $error("Mult Stage FAILED: got:%h, exp=%h", dut.mult_r, expected_mult);
        $display("PASS: Mult test %d*%d = %h", din, win, dut.mult_r);
    endtask

    task test_add(
        input int idx,
        input signed [DATA_WIDTH-1:0] din,
        input signed [DATA_WIDTH-1:0] win
        // input signed [ACCUM_WIDTH-1:0] pin
    );
        data_in = din;
        weight_in = win;
        psum_in = pin;
        repeat(4) @(posedge clk);
        
        mult_temp = dut.mult_r;
        expected_mac = pin + mult_temp[ACCUM_WIDTH-1:0];
        
        assert (dut.mac_r == expected_mac)
            else $error("Add stage FAILED: got:%h, exp=%h", dut.mac_r, expected_mac);
        // $display("PASS: Add test: psum+%h = %h", mult_temp[ACCUM_WIDTH-1:0], dut.mac_r);
        $display("PASS: Add test[%0d]: psum+%h = %h", idx, mult_temp[ACCUM_WIDTH-1:0], dut.mac_r);
    endtask

    task test_mid_reset;
        data_in = 8'd5;
        weight_in = 8'd3;
        psum_in = 32'd10;
        
        repeat(2) @(posedge clk);;
        rst_n = 1;
        @(posedge clk);

        assert (o_data === 0 && o_weight === 0 && o_psum === 0)
        else $error("Reset FAILED -- output(s) not clearned");
        assert(dut.data_r === 0 && dut.mult_r === 0 && dut.mac_r ===0);
        else $error("Reset FAILED -- internal(s) not cleared");
    endtask

    localparam NUM_TESTS = 200;
    logic [47:0] test_vecs [0:NUM_TESTS-1]; // 8 data + 8 weight + 32 psum
    logic signed [DATA_WIDTH-1:0]   test_data [0:NUM_TESTS-1];
    logic signed [DATA_WIDTH-1:0]   test_weight [0:NUM_TESTS-1];
    logic signed [ACCUM_WIDTH-1:0]  test_psum [0:NUM_TESTS-1];

    initial begin
        $dumpfile("tb_pe.vcd");
        $dumpvars(0, tb_pe);

        data_in = '0;
        weight_in = '0;
        psum_in = '0;

        $readmemh("test_vectors.hex", test_vecs);
        for (int i = 0; i < NUM_TESTS; i++) begin
            test_data[i] = test_vecs[i][47:40]; // MSB data
            test_weight[i] = test_vecs[i][39:32]; // MSB weight
            test_psum[i] = test_vecs[i][31:0]; // psum LSB
        end
        $display("Loaded %0d test vectors from test_vectors.hex", NUM_TESTS);
        
        reset_dut();

        test_mult(8'd5, 8'd3); // 15
        test_mult(-8'd2, 8'd4); //  -8

        test_add(8'd5, 8'd3, 32'd10); // 10+15=25
        test_add(-8'd2, 8'd10, -32'd20); // -20-8=-28

        repeat(10) @(posedge clk);

        test_mid_reset();

        // OVerflow
        test_mult(8'7F, 8'7F); // 127*127=16129
        test_mult(8'h80, 8'80); // -127*-127 = 16384

        $finish;
    end

endmodule