module vga (
    input clk, rst_n,
    output reg [10:0] h_count, v_count,
    output wire visible,
    output reg hsync, vsync
);
    reg [1:0] h_state, v_state;
    reg row_done;

    assign visible = (h_state == H_VISIBLE_S && v_state == V_VISIBLE_S) ? 1'b1 : 1'b0 ;

    always @(posedge clk) begin
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
                    row_done <= 0;
                    if (h_count == H_PULSE_C-1) begin
                        h_state <= H_BACK_S;
                        hsync <= 1;
                        h_count <= 0;
                    end else begin
                        h_state <= H_PULSE_S;
                        hsync <= 0;
                        h_count <= h_count + 1;
                    end
                end
                H_BACK_S : begin
                    hsync <=1;
                    if (h_count == H_BACK_C-1) begin
                        h_state <= H_VISIBLE_S;
                        row_done <= 0;
                        h_count <= 0;
                    end else if (h_count == H_BACK_C-2) begin
                        h_state <= H_BACK_S;
                        row_done <= 1;
                        h_count <= h_count + 1;
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
                    if (v_count == V_PULSE_C-1 && row_done) begin
                        v_state <= V_BACK_S;
                        vsync <=1;
                        v_count <= 0;
                    end else if(row_done)begin
                        v_state <= V_PULSE_S;
                        vsync <=0;
                        v_count <= v_count + 1;
                    end else begin
                        v_state <= v_state;
                        vsync <=0;
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