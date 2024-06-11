//This module may contain some logical errors depending on the FPGA of your choice. Use of Else-If ladder is highly recommended.
module keypad (
    input clk,
    input [3:0] row,
    output reg [3:0] col,
    output reg [3:0] ctrl,
    output [7:0] segment
);

reg [7:0] display ;

initial col = 4'b0001;
    
always @(posedge clk) ctrl = 4'b1110;
    
always @(posedge clk) begin
    case ({col, row})
        8'b00010001: display = 8'b11111100;//0
        8'b00010010: display = 8'b01100110;//4
        8'b00010100: display = 8'b11111110;//8
        8'b00011000: display = 8'b10011100;//C
        //  case (row)
        //     row[0]: display = 8'b11111100;//0
        //     row[1]: display = 8'b01100110;//4
        //     row[2]: display = 8'b11111110;//8
        //     row[3]: display = 8'b10011100;//C
        // endcase  
        8'b00100001: display = 8'b01100000;//1
        8'b00100010: display = 8'b10110110;//5
        8'b00100100: display = 8'b11110110;//9
        8'b00101000: display = 8'b01111010;//D
        
        // case (row)
        //     row[0]: display = 8'b01100000;//1
        //     row[1]: display = 8'b10110110;//5
        //     row[2]: display = 8'b11110110;//9
        //     row[3]: display = 8'b01111010;//D
        // endcase 

        8'b01000001: display = 8'b11011010;//2
        8'b01000010: display = 8'b10111110;//6
        8'b01000100: display = 8'b11101110;//A
        8'b01001000: display = 8'b10011110;//E

        // 4'b0100: case (row)
        //     row[0]: display = 8'b11011010;//2
        //     row[1]: display = 8'b10111110;//6
        //     row[2]: display = 8'b11101110;//A
        //     row[3]: display = 8'b10011110;//E
        // endcase 

        8'b10000001: display = 8'b11110010;//3
        8'b10000010: display = 8'b11100000;//7
        8'b10000100: display = 8'b00111110;//B
        8'b10001000: display = 8'b10001110;//F

        // 4'b1000: case (row)
        //     row[0]: display = 8'b11110010;//3
        //     row[1]: display = 8'b11100000;//7
        //     row[2]: display = 8'b00111110;//B
        //     row[3]: display = 8'b10001110;//F
        // endcase

    endcase
    col = ({col[2:0],col[3]});
end


assign segment = display;

endmodule