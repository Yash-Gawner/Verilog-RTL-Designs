module uart_tx_parity(
    input clk,
    input reset,
    input [7:0]in_data,
    input tx_start,
    
    //output reg [7:0]data_out,
    output reg tx,
    output reg tx_done
);

reg [7:0]shift_reg;
reg [2:0]state , next_state;

reg [12:0]baud_count;
reg baud_tik;
reg [2:0]data_count;
reg parity_reg;


parameter IDLE  = 3'b000,
          START  = 3'b001,
          DATA   = 3'b010,
          PARITY = 3'b011,
          STOP   = 3'b100;

// baud rate generator 
always @(posedge clk or posedge reset)begin
    if(reset)begin
      baud_count <= 0;
      baud_tik <= 0;
    end

    else if (baud_count == 5208)begin
        baud_count <= 0;
        baud_tik <= 1;
    end

    else begin
        baud_count <= baud_count + 1;
        baud_tik <= 0;
    end
end

// transmitted data counter
always @(posedge clk or posedge reset)begin
    if(reset)begin
        data_count <= 0;
    end

    else if(state == DATA && baud_tik) begin
        data_count <= data_count + 1;
    end

    else if(state != DATA)begin
        data_count <= 0;
    end
end

// data shifting 
always @(posedge clk or posedge reset)begin
    if(reset)begin
        shift_reg <= 0;
    end

    else if(state == IDLE && tx_start)begin
        shift_reg <= in_data;
        //parity_reg <= ^in_data;  // here when the data change the parity will not chane thats why assign will not be used
        parity_reg <= 1;
    end

    else if (state == DATA && baud_tik)begin
        shift_reg  <= shift_reg >> 1;
    end
end

//shift reg
always @(posedge clk or posedge reset)begin
    if(reset)
        state <= IDLE;

    else 
        state <= next_state;

end

// FSM logic 
always @(*)begin
    next_state = state;

    case(state)

    IDLE : begin
        next_state = tx_start ? START : IDLE;
    end

    START : begin
        if(baud_tik)
            next_state = DATA;

        else 
            next_state = START;
    end

    DATA : begin
        if(baud_tik && data_count == 3'd7)
            next_state = PARITY;

        else 
            next_state = DATA;
        //end
    end
    
    // even parity 
    PARITY : begin
        if(baud_tik)
            next_state = STOP;
        
        else 
            next_state = PARITY;
    end

    STOP : begin
        if(baud_tik)
            next_state = IDLE;

        else 
            next_state = STOP;
    end

    default : next_state = IDLE;

    endcase
end

always @(*)begin
    if(reset)
        tx <= 1;

    else begin

        case(state)

        IDLE  : tx <= 1;
        START : tx <= 0;
        DATA  : begin
            tx <= shift_reg[0];
            //data_out <= {data_out[6:0], shift_reg[0]};
        end
        PARITY  : tx <= parity_reg;
        STOP    : tx <= 1;
        default : tx <= 1;

        endcase
    end
end

always @(posedge clk or posedge reset)begin
    
    if(reset)
        tx_done <= 0;
    
    else if(state == STOP && baud_tik)
        tx_done <= 1;
    
    else 
        tx_done <= 0;
end

endmodule 