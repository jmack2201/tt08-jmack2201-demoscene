module pixel_color (
    input clk, hsync, vsync, rst_n,
    input [9:0] hpos, vpos,
    input visible,
    output reg [1:0] R,G,B
);
    reg [5:0] rom_RGB;
    sprite_rom rom (.clk(clk), .addr(8'h00), .color_out(rom_RGB));

    reg [9:0] moving_counter;

    always @(posedge vsync) begin
        if (!rst_n) begin
            moving_counter <= 0;
        end else begin
            moving_counter <= moving_counter + 1;
        end
    end

    reg [7:0] background_state;
    reg [5:0] solid_color;

    always @(posedge clk ) begin
        if (!rst_n) begin
            background_state <= 0;
            solid_color <= 6'b110000;
        end else begin
            background_state <= 0;
            solid_color <= 6'b110000;
        end
    end

    reg [9:0] moving_x, moving_y;

    always @(*) begin
        case (background_state)
            3 : begin
                moving_x = hpos + moving_counter;
            end

            4: begin
                moving_x = hpos - moving_counter;
            end

            5: begin
                moving_y = vpos + moving_counter;
            end 

            6: begin
                moving_y = vpos - moving_counter;
            end 
            7: begin
                moving_x = hpos + moving_counter;
                moving_y = vpos + moving_counter;
            end
            8: begin
                moving_x = hpos - moving_counter;
                moving_y = vpos + moving_counter;
            end
            9: begin
                moving_x = hpos + moving_counter;
                moving_y = vpos - moving_counter;
            end
            10: begin
                moving_x = hpos - moving_counter;
                moving_y = vpos - moving_counter;
            end
            default: begin
                moving_x = hpos + moving_counter;
                moving_y = vpos + moving_counter;
            end
        endcase
    end

    always @(*) begin
        if (visible) begin
            case (background_state)
                0 : begin //solid color
                    {R,G,B} = solid_color;
                end

                1: begin //vertical stripes
                    {R,G,B} = hpos[5:0];
                end

                2: begin //horizontal stripes
                    {R,G,B} = vpos[5:0];
                end

                3,4: begin //x moving
                    R = {moving_x[5],vpos[2]};
                    G = {moving_x[6],vpos[2]};
                    B = {moving_x[7],vpos[2]};
                end

                5,6: begin //y moving
                    R = {moving_y[5],vpos[2]};
                    G = {moving_y[6],vpos[2]};
                    B = {moving_y[7],vpos[2]};
                end

                7,8,9,10: begin //both moving
                    R = {moving_y[5],moving_x[2]};
                    G = {moving_y[6],moving_x[2]};
                    B = {moving_y[7],moving_x[2]};
                end

                11: begin
                    {R,G,B} = 6'b000000;
                    if (visible) begin
                        {R,G,B} = rom_RGB;
                    end
                end

                default: {R,G,B} = 6'b000000;
            endcase
        end else begin
            {R,G,B} = 6'b000000;
        end
    end

endmodule