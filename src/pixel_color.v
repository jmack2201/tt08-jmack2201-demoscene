module pixel_color (
    input clk, hsync, vsync, rst_n,
    input [9:0] hpos, vpos,
    input [7:0] vga_control,
    input visible,
    output reg [1:0] R,G,B
);

    reg [5:0] rom_RGB;
    sprite_rom rom (.clk(clk), .addr(addr), .color_out(rom_RGB));

    wire [13:0] addr = y_delta[6:0]*SPRITE_SIZE + x_delta[6:0];

    reg [9:0] sprite_left, sprite_top;
    reg x_mov, y_mov;

    wire [9:0] x_delta = hpos - sprite_left;
    wire [9:0] y_delta = vpos - sprite_top;

    reg [9:0] prev_y;

    wire in_sprite = (x_delta[9:7] == 0 && y_delta[9:7] == 0);

    always @(posedge clk ) begin
        if (!rst_n) begin
            sprite_left <= 150;
            sprite_top <= 150;
            x_mov <= 1;
            y_mov <= 0;
        end else begin
            prev_y <= vpos;
            if (vpos == 0 && prev_y != vpos) begin
                sprite_left <= sprite_left + (x_mov ? 1 : -1);
                sprite_top <= sprite_top + (y_mov ? 1 : -1);
                if (sprite_top == V_DISPLAY-SPRITE_SIZE-1 && y_mov) begin
                    y_mov <= 0;
                end
                if (sprite_top == 1 && !y_mov) begin
                    y_mov <= 1;
                end
                if (sprite_left == H_DISPLAY-SPRITE_SIZE-1 && x_mov) begin
                    x_mov <= 0;
                end
                if (sprite_left == 1 && !x_mov) begin
                    x_mov <= 1;
                end
            end
        end
    end

    reg [7:0] background_state;
    reg [5:0] solid_color;

    always @(posedge clk ) begin
        if (!rst_n) begin
            background_state <= 0;
            solid_color <= 6'b111111;
        end else begin
            background_state <= vga_control;
            solid_color <= solid_color;
        end
    end

    reg [9:0] moving_counter;

    always @(posedge vsync) begin
        if (!rst_n) begin
            moving_counter <= 0;
        end else begin
            moving_counter <= moving_counter + 1;
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


    reg [1:0] R_back, G_back, B_back;
    always @(*) begin //background color selection
        if (visible) begin
            case (background_state)
                0 : begin //solid color
                    {R_back,G_back,B_back} = solid_color;
                end

                1: begin //vertical stripes
                    R_back = {hpos[5],vpos[1]};
                    G_back = {hpos[6],vpos[1]};
                    B_back = {hpos[7],vpos[1]};
                end

                2: begin //horizontal stripes
                    R_back = {vpos[5],hpos[1]};
                    G_back = {vpos[6],hpos[1]};
                    B_back = {vpos[7],hpos[1]};
                end

                3,4: begin //x moving
                    R_back = {moving_x[5],vpos[2]};
                    G_back = {moving_x[6],vpos[2]};
                    B_back = {moving_x[7],vpos[2]};
                end

                5,6: begin //y moving
                    R_back = {moving_y[5],vpos[2]};
                    G_back = {moving_y[6],vpos[2]};
                    B_back = {moving_y[7],vpos[2]};
                end

                7,8,9,10: begin //both moving
                    R_back = {moving_y[5],moving_x[2]};
                    G_back = {moving_y[6],moving_x[2]};
                    B_back = {moving_y[7],moving_x[2]};
                end

                default: {R_back,G_back,B_back} = 6'b000000;
            endcase
        end else begin
            {R_back,G_back,B_back} = 6'b000000;
        end
    end

    always @(*) begin
        if (visible) begin
            if (in_sprite) begin
                {R,G,B} = rom_RGB;
            end else begin
                {R,G,B} = {R_back,G_back,B_back};
            end
        end else begin
            {R,G,B} = 6'b000000;
        end
    end

endmodule