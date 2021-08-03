# Simple tests for an adder module
import cocotb
from mkintegerModel import divider_model
import random
import os

from cocotb.clock import Clock
from cocotb.decorators import coroutine
from cocotb.triggers import Timer, RisingEdge, ReadOnly, FallingEdge
from cocotb_bus.monitors import Monitor
from cocotb_bus.drivers import BitDriver
from cocotb.binary import BinaryValue
from cocotb.regression import TestFactory
from cocotb_bus.scoreboard import Scoreboard
from cocotb.result import TestFailure, TestSuccess

#------------------------------------Test for signed Division------------------------------------------------------
count = int(os.environ['COUNT'])
@cocotb.test()
def divider_basic_signed_DIV_test(dut):  #14
    cocotb.fork(Clock(dut.CLK, 10,).start())
    dut.ma_set_flush_c = 1
    dut.EN_ma_set_flush = 1
    dut.RST_N = 0
    clkedge = RisingEdge(dut.CLK)

    for i in range(1):
        yield clkedge

    for it in range(count):
        A =  random.randrange(0,18446744073709551615,100)
        B = random.randrange(0,18446744073709551615,100)
        #A =  random.randrange(0,10,1)
        #B = random.randrange(0,5,1)
        opcode = 12
        funct3 = 5
        
        clkedge = RisingEdge(dut.CLK)
        
        
        
        dut.EN_ma_start <= 1
        dut.RST_N <= 1
        dut.ma_start_opcode <= BinaryValue(value=opcode,n_bits=4,bigEndian=False)
        dut.ma_start_funct3 <= BinaryValue(value=funct3,n_bits=3,bigEndian=False)
        dut.ma_start_dividend <= BinaryValue(value=A,n_bits=64,bigEndian=False)
        dut.ma_start_divisor <= BinaryValue(value=B,n_bits=64,bigEndian=False)
        yield clkedge
        
        #dut.EN_ma_start = 0        
        while(dut.mav_result.value[0] == 0):
            yield clkedge
        
        dutResultBin = dut.mav_result.value
        modelResultBin = divider_model(A,B,opcode,funct3)
       
        print('Pass: Divident={0} divisor={1} dut_result={2} exp_result={3}'.format(A, B, dutResultBin, modelResultBin))
        assert modelResultBin == dutResultBin, "Incorrect signed division: divident={0} divisor={1} dut_result={2} exp_result={3}".format(A, B, hex(dutResultBin), hex(modelResultBin))

