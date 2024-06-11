module pow_module (
    input clk,
    input reset,
    input [3:0] base,
    input [3:0] exp,
    output reg [7:0] result,
    output reg done
);

reg [3:0] counter;
reg [7:0] temp_result;
reg [1:0] state;

localparam IDLE = 2'b00;
localparam CALC = 2'b01;
localparam DONE = 2'b10;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        result <= 8'd1;
        temp_result <= 8'd1;
        counter <= 4'd0;
        state <= IDLE;
        done <= 1'b0;
    end else begin
        case (state)
            IDLE: begin
                if (exp > 0) begin
                    temp_result <= 8'd1;
                    counter <= 4'd0;
                    state <= CALC;
                    done <= 1'b0;
                end else begin
                    result <= 8'd1;
                    done <= 1'b1;
                end
            end
            CALC: begin
                if (counter < exp) begin
                    temp_result <= temp_result * base;
                    counter <= counter + 4'b1;
                end else begin
                    result <= temp_result;
                    state <= DONE;
                end
            end
            DONE: begin
                done <= 1'b1;
                state <= IDLE;
            end
        endcase
    end
end

endmodule



module alu (
    input clk,
    input reset,
    input [3:0] a,
    input [3:0] b,
    input [2:0] opcode,
    output reg [7:0] result
);

wire [7:0] result1;
wire [7:0] pow_result;
wire pow_done;

pow_module u_pow (
    .clk(clk),
    .reset(reset),
    .base(a),
    .exp(b),
    .result(pow_result),
    .done(pow_done)
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        result <= 8'b0;
    end else begin
        case (opcode)
            3'b000: result <= a + b;        // Suma
            3'b001: result <= a - b;        // Resta
            3'b010: result <= (b != 0) ? (a / b) : 8'b11111111; // División, con protección contra división por cero
            3'b011: result <= a * b;        // Multiplicación
            3'b100: begin                   // Potencia
                if (pow_done) begin
                    result <= pow_result;
                end
            end
            3'b101: result <= (a * b) / 8'd100; // Porcentaje
            default: result <= 8'b00000000;  // Por defecto, resultado es 0
        endcase
    end
    
end
assign result1 = result;

endmodule




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
reg [3:0] temp_a, temp_b; // Registros temporales para acumular los dígitos
reg loading_a, loading_b; // Flags para indicar si estamos cargando a o b

localparam STATE_IDLE = 2'b00;
localparam STATE_OP = 2'b01;
localparam STATE_B = 2'b10;
localparam STATE_CALC = 2'b11;
localparam KEY_EQ = 4'b1110; // Definir la tecla para "="

alu u_alu (
    .clk(clk),
    .reset(reset),
    .a(a),
    .b(b),
    .opcode(opcode),
    .result(result1)
);

always @(posedge clk or posedge reset) begin

    result <= result1;


    if (reset) begin
        state <= STATE_IDLE;
        a <= 4'b0000;
        b <= 4'b0000;
        temp_a <= 4'b0000;
        temp_b <= 4'b0000;
        opcode <= 3'b000;
        result <= 8'b00000000;
        op_display <= 4'b0000; // Inicializar op_display
        loading_a <= 1'b0;
        loading_b <= 1'b0;
    end else if (key_valid) begin
        case (state)
            STATE_IDLE: begin
                if (key <= 4'b1001) begin // Si es un número
                    temp_a <= temp_a * 4'd10 + key; // Acumular el número
                    loading_a <= 1'b1; // Indicamos que estamos cargando a
                end else if (key >= 4'b1010 && key <= 4'b1101) begin // Si es una operación
                    if (loading_a) begin
                        a <= temp_a; // Transferir el número acumulado a a
                        loading_a <= 1'b0; // Reiniciar la carga de a
                        temp_a <= 4'b0000; // Reiniciar temp_a
                    end
                    case (key)
                        4'b1010: opcode <= 3'b000; // +
                        4'b1011: opcode <= 3'b001; // -
                        4'b1100: opcode <= 3'b010; // /
                        4'b1101: opcode <= 3'b011; // *
                        4'b1110: opcode <= 3'b100; // Potencia (A)
                        4'b1111: opcode <= 3'b101; // Porcentaje (B)
                    endcase
                    op_display <= key; // Para mostrar la operación actual en un display (opcional)
                    state <= STATE_B; // Cambiar al estado B
                end
            end
            STATE_B: begin
                if (key <= 4'b1001) begin // Si es un número
                    temp_b <= temp_b * 4'd10 + key; // Acumular el número
                    loading_b <= 1'b1; // Indicamos que estamos cargando b
                end else if (key == KEY_EQ) begin // Si se presiona "="
                    if (loading_b) begin
                        b <= temp_b; // Transferir el número acumulado a b
                        loading_b <= 1'b0; // Reiniciar la carga de b
                        temp_b <= 4'b0000; // Reiniciar temp_b
                    end
                    result <= u_alu.result; // Asignar el resultado calculado por el módulo ALU
                    state <= STATE_IDLE;
                end
            end
        endcase
    end
end

endmodule






module calculator_top (
    input clk,
    input reset,
    input [3:0] row,
    output wire [3:0] col,
    output wire [7:0] result,
    output [3:0] op_display // Opcional, para mostrar la operación actual
);

wire [3:0] key;
wire key_valid;

keypad_mat u_keypad (
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
