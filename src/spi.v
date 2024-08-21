module spi (
    input SCLK, SSEL, MOSI,
    output reg MISO
);
    reg [2:0] spi_bit_count;

    reg [3:0] spi_byte_cnt;
    reg [7:0] spi_byte;

    always @(posedge SCLK ) begin
        if (~SSEL) begin
            MISO <= 0;
        end else begin
            MISO <= 1;
        end
    end

    always @(posedge SCLK) begin
        if (~SSEL) begin
            spi_bit_count <= 3'b000;
            spi_byte <= 8'h00;
        end else begin
            spi_bit_count <= spi_bit_count + 1;
            spi_byte <= {spi_byte[6:0], MOSI};
        end
    end

    always @(posedge SCLK ) begin
        if (~SSEL) begin
            spi_byte_cnt <= 4'h0;
        end else begin
            if (spi_bit_count == 3'b111) begin
                spi_byte_cnt <= spi_byte_cnt + 1;
            end else begin
                spi_byte_cnt <= spi_byte_cnt;
            end
        end
    end
endmodule