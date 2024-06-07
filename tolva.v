module salidas_de_valvulas(
input a,b,c,d,
output A,B,C,D,
input clk,
output reg [6:0]display1, display2, display3,
output reg clko,
output reg [24:0] contador=24'd0,
output [6:0]disp,
output reg [1:0]ct,
output [2:0]hb
);

////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////---LOGICA-COMBINACIONAL---/////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

assign A = ~((~a & ( b ^ c)) |  (a & ~b & ~c)); // funcion combinacional para la balvula de 50
assign B = ~((~a & ~b & d) | (~a & b & ~c & ~d)| (~b & ~c & d)| (a & ~b & c & ~d)); // funcion combinacional para la balvula de100
assign C = ~((~b & (c ^ d)) | (a & b & ~c & ~d)); // funcion combinacional para la balvula de200
assign D = ~(~a & ((~b & c & d) | (b & ~c & d)| (b & c & ~d)));// funcion combinacional para la balvula de 400

////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////---FIN-COMBINACIONAL---//////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////


parameter divisor=24'd54000; // para metro del divisor de frecuencia

always @ (posedge clk) //divisor de frecuencia 
begin

if(contador >= (divisor)) 
begin
contador<=24'd0;
clko<= 1'd0;
end
 else begin
contador <= contador+1;
clko<=(contador < divisor/2) ? 1'b1 : 1'b0 ;
end
end

/////////////////////////////////////////////////
////////////////---displays----//////////////////
/////////////////////////////////////////////////

always @(*)
begin
case ({a,b,c,d}) ///gfedcba
4'b0000:display3=7'b0111111;
4'b0001:display3=7'b1001111;
// 4'b0001:display3=7'b1100000;
4'b0010:display3=7'b1011011;
4'b0011:display3=7'b1101101;
4'b0100:display3=7'b0000110;
4'b0101:display3=7'b1100110;
4'b0110:display3=7'b1100110;
4'b0111:display3=7'b1111001;
4'b1000:display3=7'b0111111;
4'b1001:display3=7'b1001111;
4'b1010:display3=7'b1001111;
4'b1011:display3=7'b1111001;
4'b1100:display3=7'b1011011;
4'b1101:display3=7'b1111001;
4'b1110:display3=7'b1111001;
4'b1111:display3=7'b1111001;
endcase 
end

always @(*)
begin
case ({a,b,c,d}) ///abcdefg
4'b0000:display2=7'b0111111;
4'b0001:display2=7'b0111111;
4'b0010:display2=7'b1101101;
4'b0011:display2=7'b1101101;
4'b0100:display2=7'b1101101;
4'b0101:display2=7'b1101101;
4'b0110:display2=7'b0111111;
4'b0111:display2=7'b1010000;
4'b1000:display2=7'b1101101;
4'b1001:display2=7'b1101101;
4'b1010:display2=7'b0111111;
4'b1011:display2=7'b1010000;
4'b1100:display2=7'b0111111;
4'b1101:display2=7'b1010000;
4'b1110:display2=7'b1010000;
4'b1111:display2=7'b1010000;
endcase
end

always @(*)
begin
case ({a,b,c,d}) ///abcdefg
4'b0000:display1=7'b0111111;
4'b0001:display1=7'b0111111;
4'b0010:display1=7'b0111111;
4'b0011:display1=7'b0111111;
4'b0100:display1=7'b0111111;
4'b0101:display1=7'b0111111;
4'b0110:display1=7'b0111111;
4'b0111:display1=7'b1010000;
4'b1000:display1=7'b0111111;
4'b1001:display1=7'b0111111;
4'b1010:display1=7'b0111111;
4'b1011:display1=7'b1010000;
4'b1100:display1=7'b0111111;
4'b1101:display1=7'b1010000;
4'b1110:display1=7'b1010000;
4'b1111:display1=7'b1010000;
endcase
end
//////////////////////////////////////////////
/////////////---FIN DE DISPLAYS--/////////////
//////////////////////////////////////////////




//////////////////////////////////////////////////
///////////---CONTEO-PARA-DISPLAYS---/////////////
//////////////////////////////////////////////////

always @(posedge clko) begin //contaor con la salida del clock dividido para control de displays 
    ct <= ct+2'd1;    
    if (ct == 2'b11)
    ct <= 2'b00;
    else
    ct <= ct + 1;
  
end

assign disp = (ct == 2'b00) ? display1: // asiagnacion de valores de salida para displays segun el contador anteriror
              (ct == 2'b01) ? display2:
              (ct == 2'b10) ? display3:
              7'b00000000;

              assign hb = (ct == 2'b00) ? 3'b011:  //  bloque de control de los enables de los displays
              (ct == 2'b01) ? 3'b101:
              (ct == 2'b10) ? 3'b110:
              3'b111;

//////////////////////////////////////////////////
///////////////---FIN-DE-CONTEO---////////////////
//////////////////////////////////////////////////

endmodule
