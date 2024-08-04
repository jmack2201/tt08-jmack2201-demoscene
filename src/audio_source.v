module audio_source (
    input clk, rst_n,
    input [1:0] audio_select,
    output reg audio_out
);

    reg [27:0] tone_counter;
    always @(posedge clk ) begin
        if (!rst_n) begin
            tone_counter <= 0;
        end else begin
            tone_counter <= tone_counter + 1;
        end
    end
    wire [5:0] full_note = tone_counter[27:22]; //numerater

    reg [3:0] remainder_3_2;
    reg [2:0] octave; //quotient
    wire [3:0] note = {remainder_3_2,full_note[1:0]}; //remainder

    always @(full_note[5:2]) begin
        case (full_note[5:2])
            0: begin
                octave = 0;
                remainder_3_2 = 0;
            end
            1: begin
                octave = 0;
                remainder_3_2 = 1;
            end
            2: begin
                octave = 0;
                remainder_3_2 = 2;
            end
            3: begin
                octave = 1;
                remainder_3_2 = 0;
            end
            4: begin
                octave = 1;
                remainder_3_2 = 1;
            end
            5: begin
                octave = 1;
                remainder_3_2 = 2;
            end
            6: begin
                octave = 2;
                remainder_3_2 = 0;
            end
            7: begin
                octave = 2;
                remainder_3_2 = 1;
            end
            8: begin
                octave = 2;
                remainder_3_2 = 2;
            end
            9: begin
                octave = 3;
                remainder_3_2 = 0;
            end
            10: begin
                octave = 3;
                remainder_3_2 = 1;
            end
            11: begin
                octave = 3;
                remainder_3_2 = 2;
            end
            12: begin
                octave = 4;
                remainder_3_2 = 0;
            end
            13: begin
                octave = 4;
                remainder_3_2 = 1;
            end
            14: begin
                octave = 4;
                remainder_3_2 = 2;
            end
            15: begin
                octave = 5;
                remainder_3_2 = 0;
            end
        endcase
    end

    reg [8:0] clkdivider;
    always @(note) begin
        case (note)
            0 : clkdivider = 512-1;
            1 : clkdivider = 481-1;
            2 : clkdivider = 456-1;
            3 : clkdivider = 431-1;
            4 : clkdivider = 406-1;
            5 : clkdivider = 384-1;
            6 : clkdivider = 362-1;
            7 : clkdivider = 342-1;
            8 : clkdivider = 323-1;
            9 : clkdivider = 304-1;
            10 : clkdivider = 287-1;
            11 : clkdivider = 271-1;
            12,13,14,15 : clkdivider = 0;
        endcase
    end

    reg [8:0] note_counter;
    always @(posedge clk ) begin
        if (!rst_n) begin
            note_counter <= 0;
        end else begin
            if (note_counter == 0) begin
                note_counter <= clkdivider;
            end else begin
                note_counter <= note_counter + 1;
            end
        end
    end

    reg [7:0] octave_counter;
    always @(posedge clk ) begin
        if (!rst_n) begin
            octave_counter <= 0;
        end else begin
            if (note_counter == 0) begin
                if (octave_counter == 0) begin
                    case (octave)
                        0 : octave_counter <= 255;
                        1 : octave_counter <= 127;
                        2 : octave_counter <= 63;
                        3 : octave_counter <= 31;
                        4 : octave_counter <= 15;
                        default: octave_counter <= 7;
                    endcase
                end else begin
                    octave_counter <= octave_counter - 1;
                end
            end else begin
                octave_counter <= octave_counter;
            end
        end
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            audio_out <= 0;
        end else begin
            if (note_counter == 0 && octave_counter == 0) begin
                audio_out <= ~audio_out;
            end else begin
                audio_out <= audio_out;
            end
        end
    end

endmodule
