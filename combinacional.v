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
assign pout =  (~b & pin & ~ein & ~min) | (a & ~b & ~pin & ~ein) | (a & ~b & ~pin & ~min) | (a & pin & ~ein & ~min); ///
assign eout = (~a & ~b & ~pin & ein & ~min) | (a & b & ~pin & ~min);                                                 ///
assign mout = (~a & ~pin & ~ein & min) | (~a & b & ~pin & ~min) | (~a & b & ~ein & ~min) | (b & ~pin & ~ein & min);  ///
endmodule                                                                                                           ///
////////////////////// ////////////////////--LOGICA-DE-OPERACION--//////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
module sumador4bit (
    input [3:0] a,
    input [3:0] b,
    input cen, 
    output [3:0] s,
    output csal4
    
);

wire csal1,csal2,csal3;
sumador bit1 (.a(a[0]), .b(b[0]), .cen(cen), .s(s[0]), .csal(csal1));
sumador bit2 (.a(a[1]), .b(b[1]), .cen(csal1), .s(s[1]), .csal(csal2)); 
sumador bit3 (.a(a[2]), .b(b[2]), .cen(csal2), .s(s[2]), .csal(csal3)); 
sumador bit4 (.a(a[3]), .b(b[3]), .cen(csal3), .s(s[3]), .csal(csal4)); 
endmodule

/////////////////////////////////////////////////////////////////////////////////

module restador4bit (
    input [3:0] a,
    input [3:0] b,
    input cen, 
    output [3:0] s,
    output csal4
    
);
wire csal1,csal2,csal3;
restador bit1 (.a(a[0]), .b(b[0]), .cen(cen), .s(s[0]), .csal(csal1));
restador bit2 (.a(a[1]), .b(b[1]), .cen(csal1), .s(s[1]), .csal(csal2)); 
restador bit3 (.a(a[2]), .b(b[2]), .cen(csal2), .s(s[2]), .csal(csal3)); 
restador bit4 (.a(a[3]), .b(b[3]), .cen(csal3), .s(s[3]), .csal(csal4)); 
endmodule

/////////////////////////////////////////////////////////////////////////////////

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

//////////////////////////////////////////////////////////////////////////////////////////////////////////

module multiplicador8bit(
    input [3:0]a,
    input [3:0]b,
    output [7:0]p,
    output [15:0]m
);

    wire cout00, cout01, cout02, cout03, cout04, cout05;
    wire acarreo00, acarreo01, acarreo02, acarreo03;

    wire cout10, cout11, cout12, cout13, cout14, cout15, cout16;
    wire acarreo10, acarreo11, acarreo12, acarreo13, acarreo14;

    wire acarreo20, acarreo21, acarreo22, acarreo23, acarreo24, acarreo25;

    assign m[0] = (a[0])&(b[0]);
    assign m[1] = (a[0])&(b[1]);
    assign m[2] = (a[0])&(b[2]);
    assign m[3] = (a[0])&(b[3]);

    assign m[4] = (a[1])&(b[0]);
    assign m[5] = (a[1])&(b[1]);
    assign m[6] = (a[1])&(b[2]);
    assign m[7] = (a[1])&(b[3]);

    assign m[8] = (a[2])&(b[0]);
    assign m[9] = (a[2])&(b[1]);
    assign m[10] = (a[2])&(b[2]);
    assign m[11] = (a[2])&(b[3]);

    assign m[12] = (a[3])&(b[0]);
    assign m[13] = (a[3])&(b[1]);
    assign m[14] = (a[3])&(b[2]);
    assign m[15] = (a[3])&(b[3]);


    sumador R00 (.a(m[0]), .b(1'b0), .cen(1'b0), .s(cout00), .csal(acarreo00));
    sumador R01 (.a(m[1]), .b(m[4]), .cen(acarreo00), .s(cout01), .csal(acarreo01));
    sumador R02 (.a(m[2]), .b(m[5]), .cen(acarreo01), .s(cout02), .csal(acarreo02));
    sumador R03 (.a(m[3]), .b(m[6]), .cen(acarreo02), .s(cout03), .csal(acarreo03));
    sumador R04 (.a(0), .b(m[7]), .cen(acarreo03), .s(cout04), .csal(cout05));

    sumador R10 (.a(cout00), .b(1'b0), .cen(1'b0), .s(cout10), .csal(acarreo10));
    sumador R11 (.a(cout01), .b(1'b0), .cen(acarreo10), .s(cout11), .csal(acarreo11));
    sumador R12 (.a(cout02), .b(m[8]), .cen(acarreo11), .s(cout12), .csal(acarreo12));
    sumador R13 (.a(cout03), .b(m[9]), .cen(acarreo12), .s(cout13), .csal(acarreo13));
    sumador R14 (.a(cout04), .b(m[10]), .cen(acarreo13), .s(cout14), .csal(acarreo14));
    sumador R15 (.a(cout05), .b(m[11]), .cen(acarreo14), .s(cout15), .csal(cout16));

    sumador R20 (.a(cout10), .b(1'b0), .cen(1'b0), .s(p[0]), .csal(acarreo20));
    sumador R21 (.a(cout11), .b(1'b0), .cen(acarreo20), .s(p[1]), .csal(acarreo21));
    sumador R22 (.a(cout12), .b(1'b0), .cen(acarreo21), .s(p[2]), .csal(acarreo22));
    sumador R23 (.a(cout13), .b(m[12]), .cen(acarreo22), .s(p[3]), .csal(acarreo23));
    sumador R24 (.a(cout14), .b(m[13]), .cen(acarreo23), .s(p[4]), .csal(acarreo24));
    sumador R25 (.a(cout15), .b(m[14]), .cen(acarreo24), .s(p[5]), .csal(acarreo25));
    sumador R26 (.a(cout16), .b(m[15]), .cen(acarreo25), .s(p[6]), .csal(p[7]));

endmodule

//////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////--------------------\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
///////////////////////////////////------SELECTOR------///////////////////////////////////////////
module opcontrol (
    input [1:0] sel,       // Selector de operación: 00 = suma, 01 = resta, 10 = comparación
    input [3:0] a, b,      // Entradas de 4 bits
    //input pin, ein, min,   // Entradas adicionales para el comparador
    output reg [7:0] s,    // Salida de suma/resta y multiplicacion
    output reg sal,        // Salida de carry/borrow de suma/resta
    output reg pout,       // Salida de comparación
    output reg eout,
    output reg mout
);

    // Salidas internas de los módulos
    wire [3:0] sum_out, sub_out;
    wire [7:0] mul_out;
    wire sum_carry, sub_borrow;
    wire comp_pout, comp_eout, comp_mout;

    // Instanciar sumador, restador y comparador
    sumador4bit sumador_inst (
        .a(a),
        .b(b),
        .cen(1'b0), // Carry-in para el sumador inicial
        .s(sum_out),
        .csal4(sum_carry)
    );

    restador4bit restador_inst (
        .a(a),
        .b(b),
        .cen(1'b0), // Borrow-in para el restador inicial
        .s(sub_out),
        .csal4(sub_borrow)
    );

    comparador4bit comparador_inst (
        .a(a),
        .b(b),
        .pin(1'b0),
        .ein(1'b0),
        .min(1'b0),
        .pout4(comp_pout),
        .eout4(comp_eout),
        .mout4(comp_mout)
    );

    multiplicador8bit multiplicador_inst(
        .a(a),
        .b(b),
        .p(mul_out),


   );


    // Multiplexor para seleccionar la operación
    always @(*) begin
        // Inicializar señales de salida
        s = 4'b0000;
        sal = 1'b0;
        pout = 1'b0;
        eout = 1'b0;
        mout = 1'b0;

        case (sel)
            2'b00: begin // Suma
                s = sum_out;
                sal = sum_carry;
            end
            2'b01: begin // Resta
                s = sub_out;
                sal = sub_borrow;
            end
            2'b10: begin // Comparación
                pout = comp_pout;
                eout = comp_eout;
                mout = comp_mout;
                // pin = pin;
                // ein = ein;
                // min = min;
            end
            2'b11: begin
                s = mul_out;

            end
        endcase
    end
endmodule