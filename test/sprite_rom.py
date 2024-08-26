import PIL
import PIL.Image

with open("../src/params.v","r") as fp:
    contents = fp.readlines()
sprite_size = int([line.strip().split()[-1][:-1] for line in contents if "SPRITE" in line][0])
header = "module sprite_rom (\n\tinput clk,\n\tinput [13:0] addr,\n\toutput reg [5:0] color_out\n);\n\treg [7:0] color_arr [SPRITE_SIZE*SPRITE_SIZE-1:0];\n"
body = ""
footer = "\n\talways @(posedge clk) begin\n\t\tcolor_out <= color_arr[addr][5:0];\n\tend\nendmodule\n"

sprite = PIL.Image.open("New Piskel.png").convert("RGB")
pixels = sprite.load()

body += "\n\tinitial begin\n"
# for i in range(sprite_size*sprite_size):
#     body += f"\t\tcolor_arr[{i}] = 8\'h0F;\n"
for y in range(sprite_size):
    for x in range(sprite_size):
        lower_bits = [round(color/255 * 3) for color in pixels[x,y]]
        bit_string = "".join(f"{bits:02b}" for bits in lower_bits)
        body += f"\t\tcolor_arr[{y*sprite_size+x}] = 8\'b00{bit_string};\n"
body += "\tend\n"

with open("../src/sprite_rom.v","w") as fp:
    fp.write(header+body+footer)