module Tarea_2(
    input rst,          // Reset de la FSM
    input logic clk,    // Clock de la FSM
    input logic M,      // Botón de mantenimiento (presionado = 1, no presionado = 0)
    output logic [7:0] estado_reg // Registro de estado
);

// Declaración de parámetros
localparam ESTADO_INICIO = 2'b00;
localparam ESTADO_MANTENIMIENTO = 2'b01;
localparam ESTADO_CONT_CICLOS = 2'b10;
localparam ESTADO_ERROR = 2'b11;

// Declaración de variables
logic [7:0] contador_ciclos = 8'h0;
logic [7:0] contador_mantenimiento = 8'h0;
logic [7:0] mux_salida;
logic [1:0] estado_actual, estado_siguiente;

// Comparador con valor de 200
logic reached_200;

// FSM de control
always_ff @(posedge clk or posedge rst)
begin
    if (rst) begin
        estado_actual <= ESTADO_INICIO;
    end
    else begin
        estado_actual <= estado_siguiente;
    end
end

// State machine logic
always_comb
begin
    case (estado_actual)
        ESTADO_INICIO:
            if (M) // Button pressed
                estado_siguiente = ESTADO_MANTENIMIENTO;
            else
                estado_siguiente = ESTADO_CONT_CICLOS;
        
        ESTADO_MANTENIMIENTO:
            estado_siguiente = ESTADO_INICIO;
        
        ESTADO_CONT_CICLOS:
            if (reached_200)
                estado_siguiente = ESTADO_ERROR;
            else
                estado_siguiente = ESTADO_INICIO;
        
        ESTADO_ERROR:
            if (rst)
                estado_siguiente = ESTADO_INICIO;
            else
                estado_siguiente = ESTADO_ERROR;
					 
			default: 
				estado_siguiente = ESTADO_INICIO;
    endcase
end

// Contador de ciclos
always_ff @(posedge clk or posedge rst)
begin
    if (rst) begin
        contador_ciclos <= 8'h0;
    end
    else begin
        case (estado_actual)
            ESTADO_MANTENIMIENTO:
                contador_ciclos <= 8'h0; // Reset to 0
            ESTADO_CONT_CICLOS:
                contador_ciclos <= contador_ciclos + 1;
            default:
                contador_ciclos <= contador_ciclos;
        endcase
    end
end

// Comparador con valor de 200
assign reached_200 = (contador_ciclos == 8'hC8);

// Contador de mantenimiento
always_ff @(posedge clk)
begin
    if(estado_actual == ESTADO_MANTENIMIENTO)
        contador_mantenimiento <= contador_mantenimiento + 1;
end

// Mux con valor OxFF truncado
always_comb
begin
    if (estado_actual == ESTADO_ERROR)
        mux_salida = 8'hFF;
    else
        mux_salida = contador_mantenimiento;
end

// Regulador de estado
assign estado_reg = mux_salida;

endmodule
