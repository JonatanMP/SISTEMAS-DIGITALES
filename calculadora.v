module calculadora (
    input [3:0] a, b,  /// entradas de la operacion
    output [7:0] resul /// resultado de la operacion
);
 sum sumatoria (.a(a), .b(b), .resul(resul));

endmodule //calculadora

module sum (
    input [3:0] a, b,  /// entradas de la operacion
    output [7:0] resul /// resultado de la operacion
);

assign resul = (a + b);

endmodule //suma de los datos

module res (
    input [3:0] a, b,  /// entradas de la operacion
    output [7:0] resul /// resultado de la operacion
);
assign resul = (a - b);

endmodule //resta de los datos

module div (
    input [3:0] a, b,  /// entradas de la operacion
    output [7:0] resul /// resultado de la operacion
);
 assign resul = (a / b);

endmodule //division de los datos

module mul (
    input [3:0] a, b,  /// entradas de la operacion
    output [7:0] resul /// resultado de la operacion
);
 assign resul = (a * b);

endmodule //multiplicasion de los datos

module pot (
    input [1:0] a, b,  /// entradas de la operacion
    output [7:0] resul /// resultado de la operacion
);
 assign resul = (a ** b);

endmodule //elevacion de los datos de los datos

module por (
    input [1:0] a, b,  /// entradas de la operacion
    output [7:0] resul /// resultado de la operacion
);
 assign resul = ((a * b)/100);

endmodule // de los datos de los datos