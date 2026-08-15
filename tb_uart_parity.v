module tb_uart_parity;
reg clk , reset;

reg [7:0]in_data;
reg tx_start;
wire tx_done;

reg rx;
wire rx_done;
wire parity_error;
wire framing_error;
wire [7:0]out_data;

wire serial_line;

uart_tx_parity tx_inst(
    .clk(clk),
    .reset(reset),
    .in_data(in_data),
    .tx_start(tx_start),
    .tx(serial_line),
    .tx_done(tx_done)
);

uart_rx_parity rx_inst(
    .clk(clk),
    .reset(reset),
    .rx(serial_line),
    .rx_done(rx_done),
    .parity_error(parity_error),
    .framing_error(framing_error),
    .out_data(out_data)
);

always #5 clk = ~clk;

initial begin

$dumpfile("tb_uart_parity.vcd");
$dumpvars(0, tb_uart_parity);

$monitor("Time = %0t | clk = %b | rst = %b | in_data = %b | tx_done = %b | out_data = %b | rx_done = %b | parity_error = %b | framing_error = %b",
          $time , clk , reset , in_data , tx_done , out_data, rx_done , parity_error , framing_error);

        
end

initial begin

    clk = 0;
    reset = 1;
    in_data = 8'hA5;
    tx_start = 0;

    #12 reset = 0;
    #12 tx_start = 1;
    #10 tx_start = 0;

    #700000; $finish;
end

endmodule