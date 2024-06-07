//////////////////////////////////////////----------------------\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//////////////////////////////////////////------COMPARADOR------///////////////////////////////////////////////////////
module comparador (                                                                                                 ///
input a, b, pin, ein, min,                                                                                          ///
output pout, eout, mout                                                                                             ///
);                                                                                                                  ///
assign pout =  (~b & pin & ~ein & ~min) | (a & ~b & ~pin & ~ein) | (a & ~b & ~pin & ~min) | (a & pin & ~ein & ~min); ///
assign eout = (~a & ~b & ~pin & ein & ~min) | (a & b & ~pin & ~min);                                                 ///
assign mout = (~a & ~pin & ~ein & min) | (~a & b & ~pin & ~min) | (~a & b & ~ein & ~min) | (b & ~pin & ~ein & min);  ///
endmodule                                                                                                           ///
////////////////////// ////////////////////--LOGICA-DE-OPERACION--//////////////////////////////////////////////////////

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
