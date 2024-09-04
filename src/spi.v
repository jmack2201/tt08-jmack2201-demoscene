module spi (
    input SCLK, SSEL, MOSI, rst_n,
    output reg MISO,
    output reg [7:0] background_state,
    output reg [5:0] solid_color,
    output reg audio_en
);
    parameter BACKGROUND_STATE = 0;
    parameter SOLID_COLOR = 1;
    parameter AUDIO_EN = 2;

    parameter SPI_REGISTER_CFG = 0;
    parameter SPI_SPRITE_CFG = 1;
    parameter SPI_AUDIO_CFG = 2;

    always @(posedge SCLK ) begin
        if (SSEL) begin
            MISO <= 0;
        end else begin
            MISO <= 1;
        end
    end

    always @(posedge SCLK) begin
        if (!rst_n) begin
            background_state <= 11;
            solid_color <= 6'b000000;
            audio_en <= 0;
        end else begin
            background_state <= background_state;
            solid_color <= solid_color;
            audio_en <= audio_en;
            if (spi_byte_valid && spi_byte_cnt % 2 != 0 && spi_byte_cnt > 1 && header_config == SPI_REGISTER_CFG) begin
                case (config_reg)
                    BACKGROUND_STATE : background_state <= spi_byte;
                    SOLID_COLOR : solid_color <= spi_byte[5:0];
                    AUDIO_EN : audio_en <= spi_byte[0];
                    default : begin
                        background_state <= background_state;
                        solid_color <= solid_color;
                        audio_en <= audio_en;
                    end
                endcase
            end
        end
    end

    reg [3:0] config_reg;
    reg [7:0] header_config;
    always @(posedge SCLK) begin
        if (SSEL) begin
            config_reg <= 4'hF;
            header_config <= 8'hFF;
        end else begin
            config_reg <= config_reg;
            header_config <= header_config;
            if (spi_byte_cnt % 2 == 0 && spi_byte_valid) begin
                config_reg <= spi_byte[3:0];
            end
            if (spi_byte_cnt == 1 && spi_byte_valid) begin
                header_config <= spi_byte;
            end
        end
    end

    reg [2:0] spi_bit_count;
    reg [7:0] spi_byte;
    always @(posedge SCLK) begin
        if (SSEL) begin
            spi_bit_count <= 3'b000;
            spi_byte <= 8'h00;
        end else begin
            spi_bit_count <= spi_bit_count + 1;
            spi_byte <= {spi_byte[6:0], MOSI};
        end
    end

    reg [3:0] spi_byte_cnt;
    reg spi_byte_valid;
    always @(posedge SCLK ) begin
        if (SSEL) begin
            spi_byte_cnt <= 4'h0;
            spi_byte_valid <= 0;
        end else begin
            if (spi_bit_count == 3'b111) begin
                spi_byte_cnt <= spi_byte_cnt + 1;
                spi_byte_valid <= 1;
            end else begin
                spi_byte_cnt <= spi_byte_cnt;
                spi_byte_valid <= 0;
            end
        end
    end
endmodule