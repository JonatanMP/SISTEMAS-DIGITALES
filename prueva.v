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


// module controller (
//     input clk,
//     input reset,
//     input [3:0] key,
//     input key_valid,
//     output reg [7:0] result,
//     output reg [3:0] op_display // Opcional, para mostrar la operación actual
// );

// reg [3:0] a, b;
// reg [2:0] opcode;
// reg [1:0] state;

// localparam STATE_IDLE = 2'b00;
// localparam STATE_OP = 2'b01;
// localparam STATE_B = 2'b10;
// localparam STATE_CALC = 2'b11;

// alu u_alu (
//     .clk(clk),
//     .reset(reset),
//     .a(a),
//     .b(b),
//     .opcode(opcode),
//     .result(result1)
// );

// always @(posedge clk or posedge reset) begin
//     if (reset) begin
//         state <= STATE_IDLE;
//         a <= 4'b0000;
//         b <= 4'b0000;
//         opcode <= 3'b000;
//         result <= 8'b00000000;
//         op_display <= 4'b0000; // Inicializar op_display
//     end else if (key_valid) begin
//         case (state)
//             STATE_IDLE: begin
//                 if (key <= 4'b1001) begin // Si es un número
//                     a <= key;
//                     state <= STATE_OP;
//                 end
//             end
//             STATE_OP: begin
//                 if (key >= 4'b1010 && key <= 4'b1101) begin // Si es una operación
//                     case (key)
//                         4'b1010: opcode <= 3'b000; // +
//                         4'b1011: opcode <= 3'b001; // -
//                         4'b1100: opcode <= 3'b010; // /
//                         4'b1101: opcode <= 3'b011; // *
//                         4'b1110: opcode <= 3'b100; // Potencia (A)
//                         4'b1111: opcode <= 3'b101; // Porcentaje (B)
//                     endcase
//                     op_display <= key; // Para mostrar la operación actual en un display (opcional)
//                     state <= STATE_B;
//                 end
//             end
//             STATE_B: begin
//                 if (key <= 4'b1001) begin // Si es un número
//                     b <= key;
//                     state <= STATE_CALC;
//                 end
//             end
//             STATE_CALC: begin
//                 result <= u_alu.result; // Asignar el resultado calculado por el módulo ALU
//                 state <= STATE_IDLE;
//             end
//         endcase
//     end
// end

// endmodule

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
                    result <= u_alu.result1; // Asignar el resultado calculado por el módulo ALU
                    state <= STATE_IDLE;
                end
            end
        endcase
    end
end

endmodule

// module controller (
//     input clk,
//     input reset,
//     input [3:0] key,
//     input key_valid,
//     output reg [7:0] result,
//     output reg [3:0] op_display // Opcional, para mostrar la operación actual
// );

// reg [3:0] a, b;
// reg [2:0] opcode;
// reg [1:0] state;
// reg [1:0] op_count; // Contador para la secuencia de teclas de la operación de potencia
// reg pow_requested; // Señal para activar la operación de potencia

// localparam STATE_IDLE = 2'b00;
// localparam STATE_OP = 2'b01;
// localparam STATE_B = 2'b10;
// localparam STATE_CALC = 2'b11;

// alu u_alu (
//     .clk(clk),
//     .reset(reset),
//     .a(a),
//     .b(b),
//     .opcode(opcode),
//     .result(result)
// );

// always @(posedge clk or posedge reset) begin
//     if (reset) begin
//         state <= STATE_IDLE;
//         a <= 4'b0000;
//         b <= 4'b0000;
//         opcode <= 3'b000;
//         result <= 8'b00000000;
//         op_display <= 4'b0000; // Inicializar op_display
//         op_count <= 2'b00; // Inicializar el contador de secuencia de teclas de la operación de potencia
//         pow_requested <= 1'b0; // Inicializar la señal de operación de potencia
//     end else if (key_valid) begin
//         case (state)
//             STATE_IDLE: begin
//                 if (key <= 4'b1001) begin // Si es un número
//                     a <= key;
//                     state <= STATE_OP;
//                 end
//             end
//             STATE_OP: begin
//                 if (key >= 4'b1010 && key <= 4'b1101) begin // Si es una operación
//                     case (key)
//                         4'b1010: opcode <= 3'b000; // +
//                         4'b1011: opcode <= 3'b001; // -
//                         4'b1100: opcode <= 3'b010; // /
//                         4'b1101: opcode <= 3'b011; // *
//                         4'b1110: begin // Potencia (A)
//                             if (op_count == 2'b01) begin
//                                 pow_requested <= 1'b1; // Activar la operación de potencia
//                                 op_count <= 2'b00; // Reiniciar el contador de secuencia de teclas
//                             end else begin
//                                 op_count <= 2'b01; // Incrementar el contador de secuencia de teclas
//                             end
//                         end
//                         4'b1111: opcode <= 3'b101; // Porcentaje (B)
//                     endcase
//                     op_display <= key; // Para mostrar la operación actual en un display (opcional)
//                     state <= STATE_B;
//                 end
//             end
//             STATE_B: begin
//                 if (key <= 4'b1001) begin // Si es un número
//                     b <= key;
//                     state <= STATE_CALC;
//                 end
//             end
//             STATE_CALC: begin
//                 result <= u_alu.result; // Asignar el resultado calculado por el módulo ALU
//                 state <= STATE_IDLE;
//             end
//         endcase
//     end
// end

// endmodule




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


// module calculator_top (
//     input clk,
//     input reset,
//     input [3:0] row,
//     output [3:0] col,
//     output reg [7:0] result,
//     output reg [3:0] op_display // Opcional, para mostrar la operación actual
// );

// wire [3:0] key;
// wire key_valid;

// keypad_mat u_keypad (
//     .clk(clk),
//     .reset(reset),
//     .row(row),
//     .col(col),
//     .key(key),
//     .key_valid(key_valid)
// );

// reg [7:0] controller_result; // Variable para almacenar el resultado del controller
// reg [3:0] controller_op_display; // Variable para mostrar la operación actual

// controller u_controller (
//     .clk(clk),
//     .reset(reset),
//     .key(key),
//     .key_valid(key_valid),
//     .result(controller_result),
//     .op_display(controller_op_display)
// );

// // Conexión de las señales del controller a las salidas del calculator_top
// assign result = controller_result;
// assign op_display = controller_op_display;

// endmodule



module keypad_mat (
    input clk,
    input reset,
    input [3:0] row,
    output reg [3:0] col,
    output reg [3:0] key,
    output reg key_valid
);

initial col = 4'b0001; // Inicializar las columnas

always @(posedge clk or posedge reset) begin
    if (reset) begin
        col <= 4'b0001;
    end else begin
        col <= {col[2:0], col[3]}; // Cambiar columna
    end
end

always @(posedge clk) begin
    key_valid <= 0; // Restablecer la señal de validación de tecla en cada ciclo de reloj
    if (col == 4'b0001) begin
        if (row[0] == 1) begin key <= 4'b0000; key_valid <= 1; end // 0
        else if (row[1] == 1) begin key <= 4'b0100; key_valid <= 1; end // 4
        else if (row[2] == 1) begin key <= 4'b1000; key_valid <= 1; end // 8
        else if (row[3] == 1) begin key <= 4'b1100; key_valid <= 1; end // C
    end
    else if (col == 4'b0010) begin
        if (row[0] == 1) begin key <= 4'b0001; key_valid <= 1; end // 1
        else if (row[1] == 1) begin key <= 4'b0101; key_valid <= 1; end // 5
        else if (row[2] == 1) begin key <= 4'b1001; key_valid <= 1; end // 9
        else if (row[3] == 1) begin key <= 4'b1101; key_valid <= 1; end // D
    end
    else if (col == 4'b0100) begin
        if (row[0] == 1) begin key <= 4'b0010; key_valid <= 1; end // 2
        else if (row[1] == 1) begin key <= 4'b0110; key_valid <= 1; end // 6
        else if (row[2] == 1) begin key <= 4'b1010; key_valid <= 1; end // A
        else if (row[3] == 1) begin key <= 4'b1110; key_valid <= 1; end // E
    end
    else if (col == 4'b1000) begin
        if (row[0] == 1) begin key <= 4'b0011; key_valid <= 1; end // 3
        else if (row[1] == 1) begin key <= 4'b0111; key_valid <= 1; end // 7
        else if (row[2] == 1) begin key <= 4'b1011; key_valid <= 1; end // B
        else if (row[3] == 1) begin key <= 4'b1111; key_valid <= 1; end // F
    end
end

endmodule
