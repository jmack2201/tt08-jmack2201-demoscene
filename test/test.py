# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import PIL
from PIL import Image
from PIL import ImageChops
import cocotb
import os
import pprint as pp
from cocotb.clock import Clock
from cocotb.triggers import Timer, FallingEdge, RisingEdge

pprint = pp.PrettyPrinter()

#read in VGA config
vga_cfg_contents = ""
with open("../src/vga_cfg.v","r") as fp:
    vga_cfg_contents = fp.readlines()

vga_params = [int(param.strip()[:-1].split()[-1]) for param in vga_cfg_contents if param != "\n" and "_S" not in param]

H_VISIBLE = vga_params[0]
H_FRONT = vga_params[1]
H_PULSE = vga_params[2]
H_BACK = vga_params[3]
V_VISIBLE = vga_params[4]
V_FRONT = vga_params[5]
V_PULSE = vga_params[6]
V_BACK = vga_params[7]

def generate_frame():
    pass

async def start_test(dut):
    dut._log.info("Starting test...")
    
    dut._log.info("Starting clock...")
    await cocotb.start(start_clock(dut))

    dut._log.info("Reseting design...")
    await reset(dut)

async def reset(dut):
    # Reset
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await Timer(100, "ns")
    dut.rst_n.value = 1


async def grab_frame(dut):
    gen_image = PIL.Image.new("RGB",(H_VISIBLE,V_VISIBLE), "orange")
    pixel_array = gen_image.load()
    x = 0
    y = 0
    while(1):
        await RisingEdge(dut.clk)

        r = dut.user_project.wrapper.vga.vga_r.value << 6
        g = dut.user_project.wrapper.vga.vga_g.value << 6
        b = dut.user_project.wrapper.vga.vga_b.value << 6

        if (r & 1<<6):
            r = r | 0x3F
        if (g & 1<<6):
            g = g | 0x3F
        if (b & 1<<6):
            b = b | 0x3F

        if x >= 0 and x < H_VISIBLE and y >= 0 and y < V_VISIBLE:
            pixel_array[x,y] = (r,g,b)

        if dut.user_project.wrapper.vga.row_done == 1:
            y += 1
            x = 0
        else:
            x += 1

        if dut.user_project.wrapper.vga.v_state.value.integer == 1:
            return gen_image
        
def golden_frame():
    image = PIL.Image.new("RGB",(H_VISIBLE,V_VISIBLE))
    pixels = image.load()
    for y in range(V_VISIBLE):
        for x in range(H_VISIBLE):
            pixels[x,y] = (0,0,255)
    return image

async def start_clock(dut):
    c = Clock(dut.clk, 39.8, units="ns")
    await c.start()

@cocotb.test()
async def run_VGA_single_frame(dut):
    await start_test(dut)


    end_frame = await cocotb.start(grab_frame(dut))
    frame = await end_frame.join()
    frame.save("test.png")
    golden_image = golden_frame()
    golden_image.save("golden.png")
    await FallingEdge(dut.user_project.wrapper.vga.frame_done)

    image_difference = PIL.ImageChops.difference(frame, golden_image)

    assert(not image_difference.getbbox())