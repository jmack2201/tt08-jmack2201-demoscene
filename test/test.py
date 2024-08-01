# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles
from cocotb.triggers import Timer


async def reset(dut):
    # Reset
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await Timer(10, "ns")
    dut.rst_n.value = 1

async def start_clock(dut):
    c = Clock(dut.clk, 39.8, units="ns")
    await c.start()

@cocotb.test()
async def run_VGA(dut):
    dut._log.info("Starting test...")
    
    dut._log.info("Starting clock...")
    await cocotb.start(start_clock(dut))

    dut._log.info("Reseting design...")
    await reset(dut)

    dut._log.info("Testing H and V sync generation...")

    await Timer(1000, units="us")
