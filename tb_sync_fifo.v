module tb_sync_fifo;
reg clk;
reg rst;
reg en_read;
reg en_write;
reg [7:0]data_in;
wire [7:0]data_out;
wire full_flag;
wire empty_flag;

sync_fifo uut(
    .clk(clk),
    .reset(rst),
    .read_en(en_read),
    .write_en(en_write),
    .in_data(data_in),
    .out_data(data_out),
    .full(full_flag),
    .empty(empty_flag)
);

always #5 clk = ~clk;

initial begin

    $dumpfile("tb_sync_fifo.vcd");
    $dumpvars(0, tb_sync_fifo);

    $monitor("time = %0t | clk = %b | rst = %b |count = %b | en_read = %b | en_write = %b | data_in = %b | data_out = %b | full_flag = %b | empty_flag = %b",
             $time , clk , rst , count , en_read , en_write , data_in, data_out , full_flag , empty_flag);

    clk =0;
    rst = 1;
    en_read = 0;
    en_write = 0;
    data_in = 8'b0;

    #10 rst = 0;
    
    #12
    en_write = 1;
    data_in = 8'h34;
    
    #10
    data_in = 8'h43;
    
    #10
    data_in = 8'h55;

    #10 en_write = 0;

    #10 en_read = 1;

    #20 en_read = 0;

    #60 $finish;


end

endmodule