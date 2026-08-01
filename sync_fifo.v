module sync_fifo(
    input clk,
    input reset,
    input read_en,
    input write_en,
    input [7:0]in_data,

    output reg [7:0]out_data,
    output full,
    output empty
);

reg [7:0]mem[0:15];
reg [4:0]count;
reg [3:0]read_ptr;
reg [3:0]write_ptr;

assign empty = (count ==0);
assign full = (count == 16);

always @(posedge clk or posedge reset)begin

    if(reset)begin
        count <= 0;
        read_ptr <= 0;
        write_ptr <= 0;
        out_data <= 0;
    end

    else if(write_en && read_en)begin
        
        // FIFO is empty
                // Only write can happen
                if(empty)
                begin
                    mem[write_ptr] <= in_data;
                    write_ptr <= write_ptr + 1;
                    count <= count + 1;
                end


                // FIFO is full
                // Only read can happen
                else if(full)
                begin
                    out_data <= mem[read_ptr];
                    read_ptr <= read_ptr + 1;
                    count <= count - 1;
                end


                // Normal condition
                // One read and one write
                else
                begin
                    mem[write_ptr] <= in_data;
                    write_ptr <= write_ptr + 1;

                    out_data <= mem[read_ptr];
                    read_ptr <= read_ptr + 1;

                    // Count remains same
                    count <= count;
                end
    end

    // only write 
    else if(write_en && !full)begin

        mem[write_ptr] <= in_data;

        write_ptr <= write_ptr + 1;
        count <= count + 1;
    end
    
    // only read
    else if(read_en && !empty)begin

        out_data <= mem[read_ptr];

        read_ptr <= read_ptr + 1;
        count <= count - 1;

    end 
end

endmodule 