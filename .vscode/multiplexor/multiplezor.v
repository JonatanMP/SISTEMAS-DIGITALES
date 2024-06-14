/////////////////////////////////////////////////
// matricula 2022_0384                         //
// como es mayor a 45 la dividimos entre 2     //
// entonces tenemos que 84 / 2 = 42            //
// 42 seria nuestra primera frecuencia         //
// para las otras entonces seria               //
// 4 la segunda frecuencia y luego             // 
// 4 + 8 =12 para la tercera y asi seguimos    //
/////////////////////////////////////////////////

/////////////////////////////////////////////////
// F1 = 42, F2 = 4, F3 = 12, F4 = 20, F5 = 28  //
// F6 = 36, F7 = 44, F8 = 52                   //
/////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

module clocks (
    input  clk,
    output reg F1,
    output reg F2,
    output reg F3,
    output reg F4,
    output reg F5,
    output reg F6,
    output reg F7,
    output reg F8,
    output reg clkdis
);


reg [24:0]contador1 = 25'd0, contador2 = 25'd0, contador3 = 25'd0, contador4 = 25'd0;
reg [24:0]contador5 = 25'd0, contador6 = 25'd0, contador7 = 25'd0, contador8 = 25'd0, contador9 = 25'b0;
parameter divf1 = 25'd642_858;
parameter divf2 = 25'd6_750_000;
parameter divf3 = 25'd2_250_000;
parameter divf4 = 25'd1_350_000;
parameter divf5 = 25'd964_286;
parameter divf6 = 25'd750_000;
parameter divf7 = 25'd613_637;
parameter divf8 = 25'd519_231;
parameter divf9 = 25'd225_000;


always @(posedge clk) /// divisor de fescuencia para los 42hz en la salida
begin
    contador1 <= contador1 + 25'd1;
    if (contador1>=(divf1-1)) begin
        contador1 <= 25'd0;
    end
    F1 <= (contador1 < (divf1/2))?1'b1:1'b0;
end

always @(posedge clk) /// divisor de fescuencia para los 4hz en la salida
begin
    contador2 <= contador2 + 25'd1;
    if (contador2>=(divf2-1)) begin
        contador2 <= 25'd0;
    end
    F2 <= (contador2 < (divf2/2))?1'b1:1'b0;
end

always @(posedge clk) /// divisor de fescuencia para los 12hz en la salida
begin
    contador3 <= contador3 + 25'd1;
    if (contador3>=(divf3-1)) begin
        contador3 <= 25'd0;
    end
    F3 <= (contador3 < (divf3/2))?1'b1:1'b0;
end

always @(posedge clk) /// divisor de fescuencia para los 20hz en la salida
begin
    contador4 <= contador4 + 25'd1;
    if (contador4>=(divf4-1)) begin
        contador4 <= 25'd0;
    end
    F4 <= (contador4 < (divf4/2))?1'b1:1'b0;
end

always @(posedge clk) /// divisor de fescuencia para los 28hz en la salida
begin
    contador5 <= contador5 + 25'd1;
    if (contador5>=(divf5-1)) begin
        contador5 <= 25'd0;
    end
    F5 <= (contador5 < (divf5/2))?1'b1:1'b0;
end

always @(posedge clk) /// divisor de fescuencia para los 36hz en la salida
begin
    contador6 <= contador6 + 25'd1;
    if (contador6>=(divf6-1)) begin
        contador6 <= 25'd0;
    end
    F6 <= (contador6 < (divf6/2))?1'b1:1'b0;
end

always @(posedge clk) /// divisor de fescuencia para los 44hz en la salida
begin
    contador7 <= contador7 + 25'd1;
    if (contador7>=(divf7-1)) begin
        contador7 <= 25'd0;
    end
    F7 <= (contador7 < (divf7/2))?1'b1:1'b0;
end

always @(posedge clk) /// divisor de fescuencia para los 52hz en la salida
begin
    contador8 <= contador8 + 25'd1;
    if (contador8>=(divf8-1)) begin
        contador8 <= 25'd0;
    end
    F8 <= (contador8 < (divf8/2))?1'b1:1'b0;
end  

always @(posedge clk) ///Este se utiliza para comtrolar el display 
begin
    contador9 <= contador9 + 25'd1;
    if (contador9>=(divf8-1)) begin
        contador9 <= 25'd0;
    end
    clkdis <= (contador9 < (divf9/2))?1'b1:1'b0;
end  
endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

module multiplexor (
    input [2:0] selector,
    input  clk,
    output [6:0] display, 
    output reg mux,
    output [1:0]enable
);

wire F1;
wire F2;
wire F3;
wire F4;
wire F5;
wire F6;
wire F7;
wire F8;
wire clkdis;
wire clkdis2;


assign clkdis2 = clkdis;


clocks F1o(  /// instanciaciones para el modulo de frecuencia tomando todas las salidas y la entrada de clk
    .clk(clk), 
    .F1(F1), 
    .F2(F2), 
    .F3(F3), 
    .F4(F4), 
    .F5(F5), 
    .F6(F6), 
    .F7(F7), 
    .F8(F8),
    .clkdis(clkdis)
    ); 

displays disp1( /// instanciacion del modulo de display tomando solo lo que entra y sale.
    .clkdis(clkdis), 
    .display(display), 
    .enable(enable), 
    .selector(selector));

always @(*) //// aqui hacemos que este bloque se repita simpre que se de algun cambio
begin

    case (selector) /// este case junto con las instanciaciones de clocks seria nuestro mux 

        3'b000: mux = F1;
        3'b001: mux = F2;
        3'b010: mux = F3;
        3'b011: mux = F4;
        3'b100: mux = F5;
        3'b101: mux = F6;
        3'b110: mux = F7;
        3'b111: mux = F8;
            
    endcase
end  
endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

module displays (
    input [2:0] selector,
    // input clk,
    output [6:0] display,
    output [1:0] enable,
    input clkdis 

);

reg cont = 1'b0;
reg [6:0] display1, display2;


always @(posedge clkdis) begin // contador para display de 7 segmetos 2bits
    cont <= ~cont;
end

assign display = cont ? display2 : display1; // asignacion de los displays 
assign enable = cont? 2'b01: 2'b10; // control de los enables del display


/////////////////////////////////////////////////
// F1 = 42, F2 = 4, F3 = 12, F4 = 20, F5 = 28  //
// F6 = 36, F7 = 44, F8 = 52                   //
/////////////////////////////////////////////////

always @(*) begin
    case (selector) ///mux insterno del display para decidir que mostrar en el display1
        3'b000: display1 = 7'b1101101;
        3'b001: display1 = 7'b0110011;
        3'b010: display1 = 7'b1101101;
        3'b011: display1 = 7'b1111110;
        3'b100: display1 = 7'b1111111;
        3'b101: display1 = 7'b1011111;
        3'b110: display1 = 7'b0110011;
        3'b111: display1 = 7'b1101101;
    endcase
end
    
always @(*) begin
    case (selector) ///mux insterno del display para decidir que mostrar en el display2
        3'b000: display2 = 7'b0110011;
        3'b001: display2 = 7'b1111110;
        3'b010: display2 = 7'b0110000;
        3'b011: display2 = 7'b1101101;
        3'b100: display2 = 7'b1101101;
        3'b101: display2 = 7'b1111001;
        3'b110: display2 = 7'b0110011;
        3'b111: display2 = 7'b1011011;
    endcase
end
    

endmodule

//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
