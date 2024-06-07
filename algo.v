module tmatrix (     //teclado matrixial//
    input [3:0] filas, // columnas del keypad

    input clk,
    output reg [3:0] a,
    output reg [3:0] b,
    output reg [3:0] col = 4'b0000,
    output reg [3:0]valor,
    output reg [3:0]dato1,
    output reg [3:0]dato2,
    output reg barr,
    output reg fcont,
    output reg reset,
    output reg result,
    output clkot
);

clkdivider clk1 (.clk(clk), .clkot(clkot));
// reg valor;

always @(posedge clkot) 

begin

    col <= 4'b1000;

    case (col)
        4'b0000: begin 
            barr <= 4'b1000;
        end
        4'b1000: begin 
            barr = col >> 1;
        end
        4'b0100: begin 
            barr = col >> 1;
        end
        4'b0010: begin 
            barr = col >> 1;
        end
        4'b0001: begin 
            barr <= 4'b1000;
        end
        default: barr <= 4'b1000;

    endcase

    barr <= col;


    case ({col, filas})
        8'b1000_1000: valor <= 4'h1;
        8'b1000_0100: valor <= 4'h2;
        8'b1000_0010: valor <= 4'h3;
        8'b1000_0001: valor <= 4'hA;
        8'b0100_1000: valor <= 4'h4;
        8'b0100_0100: valor <= 4'h5;
        8'b0100_0010: valor <= 4'h6;
        8'b0100_0001: valor <= 4'hB;
        8'b0010_1000: valor <= 4'h7;
        8'b0010_0100: valor <= 4'h8;
        8'b0010_0010: valor <= 4'h9;
        8'b0010_0001: valor <= 4'hC;
        8'b0001_1000: reset <= 1;
        8'b0001_0100: valor <= 0;
        8'b0001_0010: valor <= 12;
        8'b0001_0001: result <= 1;
        default: begin
            valor <= valor;
            reset <= 0;
            result <= 0;
        end
        
    endcase

end 

always @(filas) begin
    
    case ({filas, fcont})
        5'b1000_0: 
        begin
            dato1 <= valor;
        end
        5'b1000_1: 
        begin
            dato2 <= (dato1 * 4'd10);
            dato1 <= valor;
        end
        5'b0100_0: 
        begin
            dato1 <= valor;
        end
        5'b0100_1: 
        begin
            dato2 <= (dato1 * 4'd10);
            dato1 <= valor;
        end
        5'b0010_0: 
        begin
            dato1 <= valor;
        end
        5'b0010_1: 
        begin
            dato2 <= (dato1 * 4'd10);
            dato1 <= valor;
        end
        5'b0001_0: 
        begin
            dato1 <= valor;
        end 
        5'b0001_1: 
        begin
            dato2 <= (dato1 * 4'd10);
            dato1 <= valor;
        end
        default: valor <= valor;
    endcase
    
end
endmodule

module clkdivider (
    input clk,
    output reg clkot, //salida de relog para el teclado
    output reg [24:0] contador = 25'd0
);

parameter divisor = 25'd450000;

always @(posedge clk) 
begin
    if (contador >= (divisor+1) ) begin
        contador<=25'd0;
        clkot<=1'd0;
    end
    else begin
        contador <= contador +1;
        clkot = (contador < divisor/2) ? 1'b1 : 1'b0; 
    end
end

endmodule //teclado matrixial