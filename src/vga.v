module vga (
    input clk, rst_n,
    input [1:0] vga_state,
    output reg [1:0] vga_r, vga_b, vga_g,
    output reg hsync, vsync
);
    reg [1:0] h_state, h_state_n, v_state, v_state_n;
    reg [10:0] h_count, v_count;
    reg row_done;

    parameter [1:0] H_VISIBLE_S = 0;
    parameter [1:0] H_FRONT_S = 1;
    parameter [1:0] H_PULSE_S = 2;
    parameter [1:0] H_BACK_S = 3;

    parameter [1:0] V_VISIBLE_S = 0;
    parameter [1:0] V_FRONT_S = 1;
    parameter [1:0] V_PULSE_S = 2;
    parameter [1:0] V_BACK_S = 3;

    parameter [10:0] H_VISIBLE_C = 640;
    parameter [10:0] H_FRONT_C = 16;
    parameter [10:0] H_PULSE_C = 96;
    parameter [10:0] H_BACK_C = 48;

    parameter [10:0] V_VISIBLE_C = 400;
    parameter [10:0] V_FRONT_C = 12;
    parameter [10:0] V_PULSE_C = 2;
    parameter [10:0] V_BACK_C = 36;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            h_state <= H_VISIBLE_S;
            v_state <= V_VISIBLE_S;
            h_count <= 0;
            v_count <= 0;
            hsync <= 1;
            vsync <= 1;
            row_done <= 0;
        end else begin

            case (h_state)
                H_VISIBLE_S : begin
                    hsync <=1;
                    row_done <= 0;
                    if (h_count == H_VISIBLE_C-1) begin
                        h_state <= H_FRONT_S;
                        h_count <= 0;
                    end else begin
                        h_state <= H_VISIBLE_S;
                        h_count <= h_count + 1;
                    end
                end
                H_FRONT_S : begin
                    row_done <= 0;
                    if (h_count == H_FRONT_C-1) begin
                        h_state <= H_PULSE_S;
                        h_count <= 0;
                        hsync <=0;
                    end else begin
                        h_state <= H_FRONT_S;
                        h_count <= h_count + 1;
                        hsync <=1;
                    end
                end
                H_PULSE_S : begin
                    hsync <=0;
                    row_done <= 0;
                    if (h_count == H_PULSE_C-1) begin
                        h_state <= H_BACK_S;
                        h_count <= 0;
                    end else begin
                        h_state <= H_PULSE_S;
                        h_count <= h_count + 1;
                    end
                end
                H_BACK_S : begin
                    hsync <=1;
                    if (h_count == H_BACK_C-1) begin
                        h_state <= H_VISIBLE_S;
                        row_done <= 1;
                        h_count <= 0;
                    end else begin
                        h_state <= H_BACK_S;
                        row_done <= 0;
                        h_count <= h_count + 1;
                    end
                end
                default: begin
                    h_count <= h_count;
                    row_done <= 0;
                    hsync <= 1;
                    h_state <= H_VISIBLE_S;
                end
            endcase

            case (v_state)
                V_VISIBLE_S : begin
                    vsync <=1;
                    if (v_count == V_VISIBLE_C-1 && row_done) begin
                        v_state <= V_FRONT_S;
                        v_count <= 0;
                    end else if(row_done) begin
                        v_state <= V_VISIBLE_S;
                        v_count <= v_count + 1;
                    end else begin
                        v_state <= v_state;
                        v_count <= v_count;
                    end
                end
                V_FRONT_S : begin
                    if (v_count == V_FRONT_C-1 && row_done) begin
                        v_state <= V_PULSE_S;
                        v_count <= 0;
                        vsync <=0;
                    end else if(row_done) begin
                        v_state <= V_FRONT_S;
                        v_count <= v_count + 1;
                        vsync <=1;
                    end else begin
                        v_state <= v_state;
                        v_count <= v_count;
                        vsync <=1;
                    end
                end
                V_PULSE_S : begin
                    vsync <=0;
                    if (v_count == V_PULSE_C-1 && row_done) begin
                        v_state <= V_BACK_S;
                        v_count <= 0;
                    end else if(row_done)begin
                        v_state <= V_PULSE_S;
                        v_count <= v_count + 1;
                    end else begin
                        v_state <= v_state;
                        v_count <= v_count;
                    end
                end
                V_BACK_S : begin
                    vsync <=1;
                    if (v_count == V_BACK_C-1 && row_done) begin
                        v_state <= V_VISIBLE_S;
                        v_count <= 0;
                    end else if(row_done)begin
                        v_state <= V_BACK_S;
                        v_count <= v_count + 1;
                    end else begin
                        v_state <= v_state;
                        v_count <= v_count;
                    end
                end
                default: begin
                    v_count <= v_count;
                    vsync <= 1;
                    v_state <= V_VISIBLE_S;
                end
            endcase
        end
    end

endmodule