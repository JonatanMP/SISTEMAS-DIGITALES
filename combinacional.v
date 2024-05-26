//////////////////////////////------------------\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
/////////////////////////////------SUMADOR------/////////////////////////////////////
module sumador (                                                                  ///
input a, b, cen,                                                                  ///
output s, csal                                                                    ///
);                                                                                ///
assign s=  (~a & ~b & cen) | (~a & b & ~cen) | (a & ~b & ~cen) | (a & b & cen);   ///
assign csal= (b & cen) | (a & cen) | (b & a);                                     ///  
endmodule                                                                         ///
/////////////////////////////--LOGICA-DE-OPERACION--/////////////////////////////////


//////////////////////////////-------------------\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
/////////////////////////////------RESTADOR------////////////////////////////////////
module restador (                                                                 ///
input a, b, cen,                                                                  ///
output s, csal                                                                    ///
);                                                                                ///
assign s=  (~a & ~b & cen) | (~a & b & ~cen) | (a & ~b & ~cen) | (a & b & cen);   ///
assign csal= (b & cen) | (~a & cen) | (b & ~a);                                   ///
endmodule                                                                         ///
/////////////////////////////--LOGICA-DE-OPERACION--/////////////////////////////////


//////////////////////////////////////////----------------------\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//////////////////////////////////////////------COMPARADOR------///////////////////////////////////////////////////////
module comparador (                                                                                                 ///
input a, b, pin, ein, min,                                                                                          ///
output pout, eout, mout                                                                                             ///
);                                                                                                                  ///
assign pout=  (~b & pin & ~ein & ~min) | (a & ~b & ~pin & ~ein) | (a & ~b & ~pin & ~min) | (a & pin & ~ein & ~min); ///
assign eout= (~a & ~b & ~pin & ein & ~min) | (a & b & ~pin & ~min);                                                 ///
assign mout= (~a & ~pin & ~ein & min) | (~a & b & ~pin & ~min) | (~a & b & ~ein & ~min) | (b & ~pin & ~ein & min);  ///
endmodule                                                                                                           ///
//////////////////////////////////////////--LOGICA-DE-OPERACION--//////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
module sumador4bit (
    input [3:0] a,
    input [3:0] b,
    input cen, 
    output [3:0] s,
    output csal4,
    
);
wire csal1,csal2,csal3;
sumador bit1 (.a(a[0]), .b(b[0]), .cen(cen), .s(s[0]), .csal(csal1));
sumador bit2 (.a(a[1]), .b(b[1]), .cen(csal1), .s(s[1]), .csal(csal2)); 
sumador bit3 (.a(a[2]), .b(b[2]), .cen(csal2), .s(s[2]), .csal(csal3)); 
sumador bit4 (.a(a[3]), .b(b[3]), .cen(csal3), .s(s[3]), .csal(csal4)); 
endmodule

module restador4bit (
    input [3:0] a,
    input [3:0] b,
    input cen, 
    output [3:0] s,
    output csal4,
    
);
wire csal1,csal2,csal3;
restador bit1 (.a(a[0]), .b(b[0]), .cen(cen), .s(s[0]), .csal(csal1));
restador bit2 (.a(a[1]), .b(b[1]), .cen(csal1), .s(s[1]), .csal(csal2)); 
restador bit3 (.a(a[2]), .b(b[2]), .cen(csal2), .s(s[2]), .csal(csal3)); 
restador bit4 (.a(a[3]), .b(b[3]), .cen(csal3), .s(s[3]), .csal(csal4)); 
endmodule


module comparador4bit (
    input [3:0] a,
    input [3:0] b,
    input pin, ein, min, 
    output pout4, eout4, mout4
    
);

wire pout1,pout2,pout3;
wire eout1,eout2,eout3;
wire mout1,mout2,mout3;

comparador bit1 (.a(a[0]), .b(b[0]), .pin(pin), .ein(ein), .min(min), .pout(pout1), .eout(eout1), .mout(mout1));
comparador bit2 (.a(a[1]), .b(b[1]), .pin(pout1), .ein(eout1), .min(mout1), .pout(pout2), .eout(eout2), .mout(mout2)); 
comparador bit3 (.a(a[2]), .b(b[2]), .pin(pout2), .ein(eout2), .min(mout2), .pout(pout3), .eout(eout3), .mout(mout3)); 
comparador bit4 (.a(a[3]), .b(b[3]), .pin(pout3), .ein(eout3), .min(mout3), .pout(pout4), .eout(eout4), .mout(mout4)); 
endmodule