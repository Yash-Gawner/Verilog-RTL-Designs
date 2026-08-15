module uart_rx_parity(
    input clk,
    input reset,
    input rx,
    
    output reg rx_done,
    //output reg rx_data,
    //output reg error,
    output reg parity_error,
    output reg framing_error,
    output reg [7:0]out_data
);

reg [7:0]shift_reg;
reg [2:0]state , next_state;
reg [2:0]count_data;
reg rx_parity;
reg data_parity;
reg [12:0]baud_count;
reg baud_tik;

parameter IDLE   = 3'b000,
          START   = 3'b001,
          DATA    = 3'b010,
          PARITY  = 3'b011,
          STOP    = 3'b100;

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

// data collection
always @(posedge clk or posedge reset)begin
    if(reset)begin
        shift_reg <= 0;
        count_data <= 0;
        data_parity <= 0;
    end

    else if(state == DATA && baud_tik) begin
        shift_reg <= {rx,shift_reg[7:1]};
        count_data <= count_data + 1;

    if(count_data == 3'd7)
        data_parity <= ^{rx,shift_reg[7:1]};

    end

    else if(state != DATA)begin
        count_data <= 0;     
        data_parity <= 0;
    end
end

// parity receiving 
always @(posedge clk or posedge reset)begin
    if(reset)
        rx_parity <= 0;
    
    else if(state == PARITY && baud_tik)
        rx_parity <= rx;
end

// State register
always @(posedge clk or posedge reset)begin
    if(reset)
        state <= IDLE;
    
    else
        state <= next_state;
end

// FSm 
always @(*)begin
    next_state = state;

    case(state)

    IDLE : begin
        next_state = (!rx) ? START : IDLE;
    end

    START : begin
        next_state = (baud_tik) ? DATA : START;
    end

    DATA:begin
        if(baud_tik && count_data == 3'd7)
            next_state = PARITY;
        else
            next_state = DATA;
    end

    PARITY : begin
        next_state = (baud_tik) ? STOP : PARITY;
    end

    STOP : begin
        next_state = (baud_tik) ? IDLE : STOP;
    end

    default : next_state = IDLE;
    endcase
end

// always @(posedge clk or posedge reset)begin
//     if(reset)
//         data_parity <= 0;

//     else 
//         data_parity <= ^shift_reg;
// end

// output logic
always @(posedge clk or posedge reset)begin

  if(reset)begin
      out_data <= 0;
      rx_done <= 0;
      //error <= 0;
      parity_error <= 0;
      framing_error <= 0;
  end

  else begin
    rx_done <= 0;
    //error <= 0;
    parity_error  <= 0;
    framing_error <= 0;

    if(state==STOP && baud_tik)begin

        if(rx != 1)
            framing_error <= 1;

        else if(data_parity != rx_parity)
            parity_error <= 1;

        else begin
            out_data <= shift_reg;
            rx_done  <= 1;
        end
    end
end

end

endmodule 
