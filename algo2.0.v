module pow_module (
    input clk,
    input reset,
    input [3:0] base,
    input [3:0] exp,
    output reg [7:0] result,
    output reg done
);

// Implementación del algoritmo de exponenciación rápida
reg [7:0] x;
reg [3:0] n;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        result <= 8'd1;
        x <= 8'd1;
        n <= 4'd0;
        done <= 1'b0;
    end else begin
        if (n == 0) begin
            x <= base;
            n <= exp;
        end else begin
            if (n[0]) begin
                x <= x * base;
            end
            n <= n >> 1;
            if (n == 0) begin
                result <= x;
                done <= 1'b1;
            end
        end
    end
end

endmodule

module display_control (
    input clk,
    input btn, // Opcional: si quieres usar un botón para resetear
    input [7:0] data, // Entrada de datos (número o resultado)
    input [3:0] op, // Entrada del operador
    input display_enable, // Señal de habilitación del display
    output wire [6:0] disi2, // Salida de 7 segmentos
    output wire [3:0] hbl2 // Salida de habilitación de dígitos
);

// Divisor de frecuencia para el refresco del display
reg [27:0] counter = 28'd0;
parameter DIVISOR = 28'd50_000; // Frecuencia requerida
reg clock_out, clock;

// Registros para almacenar los valores de cada dígito
reg [3:0] digit_data;

// Contador de dígitos
reg [1:0] cout = 2'b00;

always @(posedge clk) begin
    if (counter >= DIVISOR) begin
        counter <= 28'd0;
        clock_out <= 1'b0; // Apagar si se reinicia el contador
    end else begin
        counter <= counter + 1;
        clock_out <= (counter < DIVISOR/2) ? 1'b1 : 1'b0;
    end

    // Actualizar el contador de dígitos en cada ciclo de reloj
    cout <= cout + 1;
    if (cout == 2'b11)
        cout <= 2'b00;
end

// Asignar los valores de los dígitos según las entradas
always @(posedge clock_out) begin
    case (cout)
        2'b00: digit_data <= (display_enable) ? data[7:4] : 4'b0000; // Dígito más significativo del número o resultado
        2'b01: digit_data <= (display_enable) ? data[3:0] : 4'b0000; // Dígito menos significativo del número o resultado
        2'b10: digit_data <= (display_enable) ? {1'b0, op} : 4'b0000; // Operador
        2'b11: digit_data <= 4'b0000; // No se utiliza (puedes asignar un valor si lo deseas)
    endcase
end

// Asignar las salidas del display
assign disi2 = ~display_segment(digit_data);
assign hbl2 = (cout == 2'b00) ? 4'b0111 :
              (cout == 2'b01) ? 4'b1011 :
              (cout == 2'b10) ? 4'b1101 :
              (cout == 2'b11) ? 4'b1110 : // Caso faltante agregado
              4'b0000; // Apagar si 'cout' no coincide

// Función para decodificar el valor del dígito a los segmentos del display
function [6:0] display_segment;
    input [3:0] value;
    case (value)
        4'b0000: display_segment = 7'b0000001; // 0
        4'b0001: display_segment = 7'b1001111; // 1
        4'b0010: display_segment = 7'b0010010; // 2
        4'b0011: display_segment = 7'b0000110; // 3
        4'b0100: display_segment = 7'b1001100; // 4
        4'b0101: display_segment = 7'b0100100; // 5
        4'b0110: display_segment = 7'b0100000; // 6
        4'b0111: display_segment = 7'b0001111; // 7
        4'b1000: display_segment = 7'b0000000; // 8
        4'b1001: display_segment = 7'b0000100; // 9
        default: display_segment = 7'b1111111; // Apagar el display
    endcase
endfunction

endmodule

module alu (
    input clk,
    input key_valid,
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
            if (key_valid) begin
                case (opcode)
                    3'b000: result <= a + b;        // Suma
                    3'b001: result <= a - b;        // Resta
                    3'b010: begin // División
                            if (b != 0)
                                result <= a / b;
                            else
                                result <= 8'b11111111; // Protección contra división por cero
                          end
                    3'b011: result <= a * b;        // Multiplicación
                    3'b100: begin // Potencia
                            if (pow_done)
                                result <= pow_result;
                          end
                    3'b101: result <= (a * b) / 8'd100; // Porcentaje
                    default: ; // Mantener el valor anterior de result
                endcase
            end else begin
                result <= result1;
            end
        end
    end

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
    reg [2:0] state;
    reg [3:0] temp_a, temp_b;
    reg loading_a, loading_b;
    reg div_counter;
    reg div_done;
    reg b_loaded; // Variable de estado adicional para indicar si b ha sido cargado
    reg double_mul, double_div; // Variables para rastrear dobles pulsaciones

    localparam STATE_IDLE = 4'b0000;
    localparam STATE_OP = 4'b0001;
    localparam STATE_B = 4'b0010;
    localparam STATE_CALC = 4'b0011;
    localparam STATE_POW = 4'b0100;
    localparam STATE_DIV = 4'b0101;
    localparam STATE_MUL = 4'b0110;
    localparam STATE_DIV_CALC = 4'b0111;
    localparam STATE_MUL_CALC = 4'b1000;
    localparam STATE_MUL_CALC_CALC = 4'b1001;
    localparam KEY_EQ = 4'b1110;
    localparam STATE_WAIT = 4'b1010; // Cambiar el valor de STATE_WAIT

wire [7:0] result1;

alu u_alu (
    .clk(clk),
    .key_valid(key_valid),
    .reset(reset),
    .a(a),
    .b(b),
    .opcode(opcode),
    .result(result1)
);

// Función para cargar a y b
task load_operand;
    input [3:0] operand;
    input load_a;
    begin
        if (load_a) begin
            temp_a <= temp_a * 4'd10 + operand;
        end else begin
            temp_b <= temp_b * 4'd10 + operand;
        end
    end
endtask

// Tarea para calcular división y multiplicación
task calc_div_mul;
    input [2:0] op;
    begin
        div_counter <= 1'b0;
        div_done <= 1'b0;
        if (op == 3'b010) begin // División
            state <= STATE_DIV;
        end else if (op == 3'b011) begin // Multiplicación
            state <= STATE_MUL;
        end
    end
endtask

always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= STATE_IDLE;
        a <= 4'b0000;
        b <= 4'b0000;
        temp_a <= 4'b0000;
        temp_b <= 4'b0000;
        opcode <= 3'b000;
        result <= 8'b00000000;
        op_display <= 4'b0000;
        loading_a <= 1'b0;
        loading_b <= 1'b0;
        div_counter <= 1'b0;
        div_done <= 1'b0;
        b_loaded <= 1'b0;
        double_mul <= 1'b0;
        double_div <= 1'b0;

    end else begin
        case (state)
            STATE_IDLE: begin
                if (key_valid) begin
                    if (key <= 4'b1001) begin
                        load_operand(key, 1'b1); // Cargar a
                        loading_a <= 1'b1;
                    end else if (key >= 4'b1010 && key <= 4'b1101) begin
                        if (loading_a) begin
                            a <= temp_a;
                            loading_a <= 1'b0;
                            temp_a <= 4'b0000;
                        end
                       case (key)
                            4'b1010: opcode <= 3'b000; // +
                            4'b1011: opcode <= 3'b001; // -
                            4'b1100: begin // %
                                if (double_div) begin
                                    opcode <= 3'b101; // Porcentaje
                                    double_div <= 1'b0;
                                end else begin
                                    opcode <= 3'b010; // División
                                    double_div <= 1'b1;
                                end
                            end
                            4'b1101: begin // *
                                if (double_mul) begin
                                    opcode <= 3'b100; // Potencia
                                    double_mul <= 1'b0;
                                end else begin
                                    opcode <= 3'b011; // Multiplicación
                                    double_mul <= 1'b1;
                                end
                            end
                            4'b1110: begin // Potencia (A)
                                state <= STATE_WAIT;
                                b_loaded <= 1'b0;
                            end
                            4'b1111: opcode <= 3'b010; // /
                            default: ;
                        endcase
                        state <= STATE_OP;
                    end else if (key == KEY_EQ) begin
                        state <= STATE_CALC;
                    end
                end
            end
            STATE_WAIT: begin
                if (key_valid) begin
                    if (key <= 4'b1001) begin
                        load_operand(key, 1'b0); // Cargar b
                        loading_b <= 1'b1;
                    end else if (key == KEY_EQ) begin
                        if (loading_b) begin
                            b <= temp_b;
                            loading_b <= 1'b0;
                            temp_b <= 4'b0000;
                            b_loaded <= 1'b1;
                        end
                    end
                end
                if (b_loaded) begin
                    state <= STATE_POW;
                end
            end
            STATE_OP: begin
                if (key_valid) begin
                    if (key <= 4'b1001) begin
                        load_operand(key, 1'b0); // Cargar b
                        loading_b <= 1'b1;
                    end else if (key == KEY_EQ) begin
                        if (loading_b) begin
                            b <= temp_b;
                            loading_b <= 1'b0;
                            temp_b <= 4'b0000;
                        end
                        state <= STATE_CALC;
                    end
                end
            end
            STATE_B: begin
                if (key_valid) begin
                    if (key <= 4'b1001) begin
                        load_operand(key, 1'b0); // Cargar b
                        loading_b <= 1'b1;
                    end else if (key == KEY_EQ) begin
                        if (loading_b) begin
                            b <= temp_b;
                            loading_b <= 1'b0;
                            temp_b <= 4'b0000;
                        end
                        state <= STATE_CALC;
                    end
                end
            end
            STATE_CALC: begin
                calc_div_mul(opcode);
            end
            STATE_POW: begin
                result <= result1;
                state <= STATE_IDLE;
            end
            STATE_DIV: begin
                if (div_counter < b) begin
                    div_counter <= div_counter + 1'b1;
                end else begin
                    div_done <= 1'b1;
                    state <= STATE_DIV_CALC;
                end
            end
            STATE_MUL: begin
                if (div_counter < b) begin
                    div_counter <= div_counter + 1'b1;
                end else begin
                    div_done <= 1'b1;
                    state <= STATE_MUL_CALC;
                end
            end
            STATE_DIV_CALC: begin
                if (div_done) begin
                    result <= result1;
                    state <= STATE_IDLE;
                end
            end
            STATE_MUL_CALC: begin
                if (div_done) begin
                    result <= result1;
                    state <= STATE_IDLE;
                end
            end
        endcase
    end
end

// Asignar el operador al display
always @(posedge clk or posedge reset) begin
    if (reset) begin
        op_display <= 4'b0000;
    end else begin
        case (opcode)
            3'b000: op_display <= 4'b1010; // +
            3'b001: op_display <= 4'b1011; // -
            3'b010: op_display <= 4'b1111; // /
            3'b011: op_display <= 4'b1101; // *
            3'b101: op_display <= 4'b1100; // %
            default: op_display <= 4'b0000;
        endcase
    end
end

endmodule

module calculator_top (
    input clk,
    input reset,
    input [3:0] key,
    input key_valid,
    output wire [6:0] disi2,
    output wire [3:0] hbl2
);

    wire [7:0] result;
    wire [3:0] op_display;

    controller u_controller (
        .clk(clk),
        .reset(reset),
        .key(key),
        .key_valid(key_valid),
        .result(result),
        .op_display(op_display)
    );

    display_control u_display_control (
        .clk(clk),
        .btn(reset), // Puedes usar un botón para resetear el display
        .data(result),
        .op(op_display),
        .display_enable(1'b1), // Habilitar el display
        .disi2(disi2),
        .hbl2(hbl2)
    );

endmodule

// Módulo para generar la señal key_valid
module key_controller (
    input clk,
    input reset,
    input [3:0] key,
    output reg key_valid
);

    reg [3:0] shift_reg;
    localparam KEY_VALID_SEQUENCE = 4'b1111; // Secuencia de teclas válida

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            shift_reg <= 4'b0000;
            key_valid <= 1'b0;
        end else begin
            shift_reg <= {shift_reg[2:0], key[3]}; // Desplazar a la izquierda
            if (shift_reg == KEY_VALID_SEQUENCE) begin
                key_valid <= 1'b1;
            end else begin
                key_valid <= 1'b0;
            end
        end
    end

endmodule
