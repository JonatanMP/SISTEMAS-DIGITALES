module pow_module (
    input [3:0] base,
    input [3:0] exp,
    output reg [7:0] result
);

always @(*) begin
    result = 8'd1;
    for (integer i = 0; i < exp; i = i + 1) begin
        result = result * base;
    end
end

endmodule

module alu (
    input [3:0] a,
    input [3:0] b,
    input [2:0] opcode,
    output reg [7:0] result
);

wire [7:0] pow_result;

pow_module u_pow (
    .base(a),
    .exp(b),
    .result(pow_result)
);

always @(*) begin
    case (opcode)
        3'b000: result = a + b;        // Suma
        3'b001: result = a - b;        // Resta
        3'b010: result = (b != 0) ? (a / b) : 8'b11111111; // División, con protección contra división por cero
        3'b011: result = a * b;        // Multiplicación
        3'b100: result = pow_result;   // Potencia
        3'b101: result = (a * b) / 4'd100; // Porcentaje
        default: result = 8'b00000000;  // Por defecto, resultado es 0
    endcase
end

endmodule

// El resto del código permanece igual

module controller (
    input clk,
    input reset,
    input [3:0] key,
    input key_valid,
    output reg [7:0] result,
    output reg [3:0] op_display // Opcional, para mostrar la operación actual
);

reg [3:0] a, b;
reg [2:0] opcode;
reg [1:0] state;

localparam STATE_IDLE = 2'b00;
localparam STATE_OP = 2'b01;
localparam STATE_B = 2'b10;
localparam STATE_CALC = 2'b11;

alu u_alu (
    .a(a),
    .b(b),
    .opcode(opcode),
    .result(result)
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= STATE_IDLE;
        a <= 4'b0000;
        b <= 4'b0000;
        opcode <= 3'b000;
        result <= 8'b00000000;
        op_display <= 4'b0000; // Inicializar op_display
    end else if (key_valid) begin
        case (state)
            STATE_IDLE: begin
                if (key <= 4'b1001) begin // Si es un número
                    a <= key;
                    state <= STATE_OP;
                end
            end
            STATE_OP: begin
                if (key >= 4'b1010 && key <= 4'b1101) begin // Si es una operación
                    case (key)
                        4'b1010: opcode <= 3'b000; // +
                        4'b1011: opcode <= 3'b001; // -
                        4'b1100: opcode <= 3'b010; // /
                        4'b1101: opcode <= 3'b011; // *
                        4'b1110: opcode <= 3'b100; // Potencia (A)
                        4'b1111: opcode <= 3'b101; // Porcentaje (B)
                    endcase
                    op_display <= key; // Para mostrar la operación actual en un display (opcional)
                    state <= STATE_B;
                end
            end
            STATE_B: begin
                if (key <= 4'b1001) begin // Si es un número
                    b <= key;
                    state <= STATE_CALC;
                end
            end
            STATE_CALC: begin
                result <= u_alu.result; // Asignar el resultado calculado por el módulo ALU
                state <= STATE_IDLE;
            end
        endcase
    end
end

endmodule

module calculator_top (
    input clk,
    input reset,
    input [3:0] row,
    output [3:0] col,
    output [7:0] result,
    output [3:0] op_display // Opcional, para mostrar la operación actual
);

wire [3:0] key;
wire key_valid;

matkey u_keypad (
    .clk(clk),
    .reset(reset),
    .row(row),
    .col(col),
    .key(key),
    .key_valid(key_valid)
);

controller u_controller (
    .clk(clk),
    .reset(reset),
    .key(key),
    .key_valid(key_valid),
    .result(result),
    .op_display(op_display) // Opcional
);

endmodule




module matkey (
    input clk,
    input reset,
    input [3:0] row,
    output reg [3:0] col,
    output reg [3:0] key,
    output reg key_valid
);

reg [3:0] current_col;

initial col = 4'b0001;        // Inicializar las columnas

always @(posedge clk or posedge reset) begin
    if (reset) begin
        col <= 4'b0001;
    end else begin
        col <= {col[2:0], col[3]};    // Cambiar columna
    end
end

always @(posedge clk) begin
    key_valid <= 0; // Restablecer la señal de validación de tecla en cada ciclo de reloj
    if (col==4'b0001) begin
        if (row[0]==1) begin key <= 4'b0000; key_valid <= 1; end // 0
        else if (row[1]==1) begin key <= 4'b0100; key_valid <= 1; end // 4
        else if (row[2]==1) begin key <= 4'b1000; key_valid <= 1; end // 8
        else if (row[3]==1) begin key <= 4'b1100; key_valid <= 1; end // C
    end
    else if (col==4'b0010) begin
        if (row[0]==1) begin key <= 4'b0001; key_valid <= 1; end // 1
        else if (row[1]==1) begin key <= 4'b0101; key_valid <= 1; end // 5
        else if (row[2]==1) begin key <= 4'b1001; key_valid <= 1; end // 9
        else if (row[3]==1) begin key <= 4'b1101; key_valid <= 1; end // D
    end
    else if (col==4'b0100) begin
        if (row[0]==1) begin key <= 4'b0010; key_valid <= 1; end // 2
        else if (row[1]==1) begin key <= 4'b0110; key_valid <= 1; end // 6
        else if (row[2]==1) begin key <= 4'b1010; key_valid <= 1; end // A
        else if (row[3]==1) begin key <= 4'b1110; key_valid <= 1; end // E
    end
    else if (col==4'b1000) begin
        if (row[0]==1) begin key <= 4'b0011; key_valid <= 1; end // 3
        else if (row[1]==1) begin key <= 4'b0111; key_valid <= 1; end // 7
        else if (row[2]==1) begin key <= 4'b1011; key_valid <= 1; end // B
        else if (row[3]==1) begin key <= 4'b1111; key_valid <= 1; end // F
    end
end

endmodule
