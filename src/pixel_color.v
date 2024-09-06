module pixel_color (
    input clk, hsync, vsync, rst_n,
    input [9:0] hpos, vpos,
    input [7:0] vga_control,
    input visible,
    output reg [1:0] R,G,B
);

    reg [5:0] rom0_RGB;
    reg [5:0] rom1_RGB;
    reg [5:0] rom2_RGB;
    reg [5:0] rom3_RGB;
    // sprite_rom0 rom0 (.clk(clk), .addr(addr), .color_out(rom0_RGB));
    // sprite_rom1 rom1 (.clk(clk), .addr(addr), .color_out(rom1_RGB));
    sprite_rom2 rom2 (.clk(clk), .addr(addr), .color_out(rom2_RGB));
    sprite_rom3 rom3 (.clk(clk), .addr(addr), .color_out(rom3_RGB));

    wire [11:0] addr = y_delta[5:0]*SPRITE_SIZE + x_delta[5:0];

    reg [9:0] sprite_left, sprite_top;
    reg x_mov, y_mov;

    wire [9:0] x_delta = hpos - sprite_left;
    wire [9:0] y_delta = vpos - sprite_top;

    reg [9:0] prev_y;

    wire in_sprite = (x_delta[9:6] == 0 && y_delta[9:6] == 0);

    reg [3:0] looping_background_count;
    always @(posedge clk ) begin
        if (!rst_n) begin
            sprite_left <= 150;
            sprite_top <= 150;
            x_mov <= 1;
            y_mov <= 0;
            looping_background_count <= 0;
        end else begin
            prev_y <= vpos;
            if (vpos == 0 && prev_y != vpos) begin
                sprite_left <= sprite_left + (x_mov ? 1 : -1);
                sprite_top <= sprite_top + (y_mov ? 1 : -1);
                if (sprite_top == V_DISPLAY-SPRITE_SIZE-1 && y_mov) begin
                    y_mov <= 0;
                    looping_background_count <= looping_background_count + 1;
                end
                if (sprite_top == 1 && !y_mov) begin
                    y_mov <= 1;
                    looping_background_count <= looping_background_count + 1;
                end
                if (sprite_left == H_DISPLAY-SPRITE_SIZE-1 && x_mov) begin
                    x_mov <= 0;
                    looping_background_count <= looping_background_count + 1;
                end
                if (sprite_left == 1 && !x_mov) begin
                    x_mov <= 1;
                    looping_background_count <= looping_background_count + 1;
                end
            end
        end
    end

    reg [7:0] background_state;
    reg [5:0] solid_color;
    reg [1:0] sprite_sel;

    always @(posedge clk ) begin
        if (!rst_n) begin
            background_state <= 0;
            solid_color <= 6'b111111;
            sprite_sel <= 0;
        end else begin
            case (vga_control[7:6])
                0 : begin
                    background_state <= background_state;
                    solid_color <= vga_control[5:0];
                    sprite_sel <= sprite_sel;
                end
                1 : begin
                    background_state <= background_state;
                    solid_color <= solid_color;
                    sprite_sel <= vga_control[1:0];
                end
                2 : begin
                    background_state <= vga_control[3:0];
                    solid_color <= solid_color;
                    sprite_sel <= sprite_sel;
                end
                3 : begin
                    background_state <= looping_background_count;
                    solid_color <= solid_color;
                    sprite_sel <= sprite_sel;
                end
                default: begin
                    background_state <= background_state;
                    solid_color <= solid_color;
                    sprite_sel <= sprite_sel;
                end
            endcase
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

    wire [9:0] moving_x, moving_y;

    assign moving_x = (background_state == 4 || background_state == 8 || background_state == 10) ? hpos - moving_counter : hpos + moving_counter;
    assign moving_y = (background_state == 6 || background_state == 9 || background_state == 10) ? vpos - moving_counter : vpos + moving_counter;

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

                default: {R_back,G_back,B_back} = {R_back,G_back,B_back};
            endcase
        end else begin
            {R_back,G_back,B_back} = 6'b000000;
        end
    end

    always @(*) begin
        if (visible) begin
            if (in_sprite) begin
                case (sprite_sel)
                    // 0 : {R,G,B} = rom0_RGB;
                    // 1 : {R,G,B} = rom1_RGB;
                    0 : {R,G,B} = rom2_RGB;
                    1 : {R,G,B} = rom3_RGB;
                    default: {R,G,B} = rom0_RGB;
                endcase
            end else begin
                {R,G,B} = {R_back,G_back,B_back};
            end
        end else begin
            {R,G,B} = 6'b000000;
        end
    end

endmodule