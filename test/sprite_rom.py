header = "module sprite_rom (\n\tinput clk,\n\tinput [10:0] addr,\n\toutput reg [5:0] color_out\n);\n\treg [7:0] color_arr [2047:0];\n"
body = ""
footer = "\n\talways @(posedge clk) begin\n\t\tcolor_out <= color_arr[addr][5:0];\n\tend\nendmodule\n"

body += "\n\tinitial begin\n"
for i in range(2048):
    body += f"\t\tcolor_arr[{i}] = 8\'h0F;\n"
body += "\tend\n"

with open("../src/sprite_rom.v","w") as fp:
    fp.write(header+body+footer)