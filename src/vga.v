module vga (
    input clk, rst_n,
    input [1:0] vga_state,
    output [1:0] vga_r, vga_b, vga_g,
    output hsync, vsync
);
    reg [1:0] h_state, h_state_n, v_state, v_state_n;
    reg [10:0] h_count, v_count;

    localparam H_VISIBLE_S = 0;
    localparam H_FRONT_S = 1;
    localparam H_PULSE_S = 2;
    localparam H_BACK_S = 3;

    localparam V_VISIBLE_S = 0;
    localparam V_FRONT_S = 1;
    localparam V_PULSE_S = 2;
    localparam V_BACK_S = 3;

    localparam H_VISIBLE_C = 639;
    localparam H_FRONT_C = 15;
    localparam H_PULSE_C = 95;
    localparam H_BACK_C = 47;

    localparam V_VISIBLE_C = 399;
    localparam V_FRONT_C = 11;
    localparam V_PULSE_C = 1;
    localparam V_BACK_C = 35;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            h_state <= H_VISIBLE_S;
            v_state <= V_VISIBLE_S;
            h_count <= 0;
            v_count <= 0;
            hsync <= 0;
        end else begin

            case (h_state)
                H_VISIBLE_S : begin
                    hsync <=1;
                    if (h_count == H_VISIBLE_C) begin
                        h_state_n <= H_FRONT_S;
                        h_count <= 0;
                    end else begin
                        h_state_n <= H_VISIBLE_S;
                        h_count <= h_count + 1;
                    end
                end
                H_FRONT_S : begin
                    hsync <=1;
                    if (h_count == H_FRONT_C) begin
                        h_state_n <= H_PUSLE_S;
                        h_count <= 0;
                    end else begin
                        h_state_n <= H_FRONT_S;
                        h_count <= h_count + 1;
                    end
                end
                H_PULSE_S : begin
                    h_sync <=0;
                    if (h_count == H_PUSLE_C) begin
                        h_state_n <= H_BACK_S;
                        h_count <= 0;
                    end else begin
                        h_state_n <= H_PULSE_S;
                        h_count <= h_count + 1;
                    end
                end
                H_BACK_S : begin
                    hsync <=1;
                    if (h_count == H_BACK_C) begin
                        h_state_n <= H_VISIBLE_S;
                        h_count <= 0;
                    end else begin
                        h_state_n <= H_BACK_S;
                        h_count <= h_count + 1;
                    end
                end
                default: begin
                    h_count <= h_count;
                    hsync <= 1;
                    h_state_n <= H_VISIBLE_S;
                end
            endcase

            case (v_state)
                V_VISIBLE_S : begin
                    vsync <=1;
                    if (v_count == V_VISIBLE_C) begin
                        v_state_n <= V_FRONT_S;
                        v_count <= 0;
                    end else begin
                        v_state_n <= V_VISIBLE_S;
                        v_count <= v_count + 1;
                    end
                end
                V_FRONT_S : begin
                    vsync <=1;
                    if (v_count == V_FRONT_C) begin
                        v_state_n <= V_PUSLE_S;
                        v_count <= 0;
                    end else begin
                        v_state_n <= V_FRONT_S;
                        v_count <= v_count + 1;
                    end
                end
                V_PULSE_S : begin
                    sync <=0;
                    if (v_count == V_PUSLE_C) begin
                        v_state_n <= V_BACK_S;
                        v_count <= 0;
                    end else begin
                        v_state_n <= V_PULSE_S;
                        v_count <= v_count + 1;
                    end
                end
                V_BACK_S : begin
                    vsync <=1;
                    if (v_count == V_BACK_C) begin
                        v_state_n <= V_VISIBLE_S;
                        v_count <= 0;
                    end else begin
                        v_state_n <= V_BACK_S;
                        v_count <= v_count + 1;
                    end
                end
                default: begin
                    v_count <= v_count;
                    vsync <= 1;
                    v_state_n <= V_VISIBLE_S;
                end
            endcase
            h_state <= h_state_n;
            v_state <= v_state_n;
        end
    end

endmodule