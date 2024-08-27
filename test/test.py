# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

# import PIL
# from PIL import Image
# from PIL import ImageChops
import cocotb
import os
import pprint as pp
from cocotb.clock import Clock
from cocotb.triggers import Timer, FallingEdge, RisingEdge, ClockCycles
from cocotb.binary import BinaryValue

pprint = pp.PrettyPrinter()

#read in VGA config
# vga_cfg_contents = ""
# with open("../src/vga_cfg.v","r") as fp:
#     vga_cfg_contents = fp.readlines()

# vga_params = [int(param.strip()[:-1].split()[-1]) for param in vga_cfg_contents if param != "\n" and "_S" not in param]

# H_VISIBLE = vga_params[0]
# H_FRONT = vga_params[1]
# H_PULSE = vga_params[2]
# H_BACK = vga_params[3]
# V_VISIBLE = vga_params[4]
# V_FRONT = vga_params[5]
# V_PULSE = vga_params[6]
# V_BACK = vga_params[7]

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
    dut.uio_in[3].value = 0
    dut.uio_in[4].value = 0
    dut.uio_in[5].value = 0
    dut.uio_in[6].value = 0
    dut.uio_in[7].value = 0
    dut.rst_n.value = 0
    await start_spi(dut)
    await ClockCycles(dut.clk, 10)
    await FallingEdge(dut.clk)
    dut.rst_n.value = 1

async def start_spi(dut):
    dut.uio_in[1].value = 1
    dut.uio_in[2].value = 0
    cocotb.start_soon(start_spi_clock(dut))

async def start_spi_transmission(dut):
    await FallingEdge(dut.user_project.wrapper.SCLK)
    dut.uio_in[1].value = 0

async def end_spi_transmission(dut):
    await FallingEdge(dut.user_project.wrapper.SCLK)
    dut.uio_in[1].value = 1

async def send_spi_byte(dut, byte_i):
    for bit in byte_i:
        dut.uio_in[2].value = bit
        await FallingEdge(dut.user_project.wrapper.SCLK)

# async def grab_frame(dut):
#     gen_image = PIL.Image.new("RGB",(H_VISIBLE,V_VISIBLE), "orange")
#     pixel_array = gen_image.load()
#     x = 0
#     y = 0
#     while(1):
#         await RisingEdge(dut.clk)

#         r = dut.user_project.wrapper.vga.vga_r.value << 6
#         g = dut.user_project.wrapper.vga.vga_g.value << 6
#         b = dut.user_project.wrapper.vga.vga_b.value << 6

#         if (r & 1<<6):
#             r = r | 0x3F
#         if (g & 1<<6):
#             g = g | 0x3F
#         if (b & 1<<6):
#             b = b | 0x3F

#         if x >= 0 and x < H_VISIBLE and y >= 0 and y < V_VISIBLE:
#             pixel_array[x,y] = (r,g,b)

#         if dut.user_project.wrapper.vga.row_done.value == 1:
#             y += 1
#             x = 0
#         else:
#             x += 1

#         if dut.user_project.wrapper.vga.v_state.value.integer == 1:
#             return gen_image
        
# def golden_frame(vga_control):
#     image = PIL.Image.new("RGB",(H_VISIBLE,V_VISIBLE))
#     pixels = image.load()
#     if vga_control == 0:
#         pixel = (255,0,0)
#     elif vga_control == 1:
#         pixel = (0,255,0)
#     elif vga_control == 2:
#         pixel = (0,0,255)
#     elif vga_control == 3:
#         pixel = (255,255,255)
#     for y in range(V_VISIBLE):
#         for x in range(H_VISIBLE):
#             pixels[x,y] = pixel
#     return image

async def start_clock(dut):
    c = Clock(dut.clk, 39.8, units="ns")
    await c.start()

async def start_spi_clock(dut):
    c = Clock(dut.uio_in[0], 39.8, units="ns")
    await c.start()

# @cocotb.test()
# async def reset_design(dut):
#     await start_test(dut)

@cocotb.test()
async def configure_spi_registers(dut):
    await start_test(dut)

    await ClockCycles(dut.clk, 5)
    await start_spi_transmission(dut)
    await send_spi_byte(dut,BinaryValue(255,8))
    # await ClockCycles(dut.clk, 10)
    assert dut.user_project.wrapper.spi.spi_byte.value == BinaryValue(255,8)
    await end_spi_transmission(dut)

    await Timer(1, "ms")
