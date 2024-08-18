module pwm (
    input clk, rst_n,
    input [7:0] sample,
    output reg pwm_out
);
    reg [7:0] pwm_count;
    always @(posedge clk ) begin
        if (!rst_n) begin
            pwm_count <= 0;
            pwm_out <= 0;
        end else begin
            pwm_out <= pwm_count < sample;

            if (pwm_count == 8'hfe) begin
                pwm_count <= 0;
            end else begin
                pwm_count <= pwm_count + 1;
            end
        end
    end
endmodule