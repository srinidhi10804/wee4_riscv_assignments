# Simple tests for an adder module
import cocotb
from mkintegerModel import divider_model
import random
from cocotb.clock import Clock
from cocotb.decorators import coroutine
from cocotb.triggers import Timer, RisingEdge, ReadOnly, FallingEdge
from cocotb.monitors import Monitor
from cocotb.drivers import BitDriver
from cocotb.binary import BinaryValue
from cocotb.regression import TestFactory
from cocotb.scoreboard import Scoreboard
from cocotb.result import TestFailure, TestSuccess

#------------------------------------Test for signed Division------------------------------------------------------
r = 1000
@cocotb.test()
def divider_basic_signed_DIV_test(dut):  #14
	cocotb.fork(Clock(dut.CLK, 10,).start())
	  #fixed..
	dut.ma_set_flush_c = 1
	dut.EN_ma_set_flush = 1
	dut.RST_N = 0
	clkedge = RisingEdge(dut.CLK)
	for i in range(1):
		yield clkedge
	for it in range(r):
		A =  random.randrange(0,18446744073709551615,100)
		B = random.randrange(0,18446744073709551615,100)
		opcode = 12
		funct3 = 5

		clkedge = RisingEdge(dut.CLK)
        
		
        
		dut.EN_ma_start = 1
		dut.RST_N = 1
		dut.ma_start_opcode = BinaryValue(value=opcode,n_bits=4,bigEndian=False)
		dut.ma_start_funct3 = BinaryValue(value=funct3,n_bits=3,bigEndian=False)
		dut.ma_start_dividend = BinaryValue(value=A,n_bits=64,bigEndian=False)
		dut.ma_start_divisor = BinaryValue(value=B,n_bits=64,bigEndian=False)
		yield clkedge
        
	        #dut.EN_ma_start = 0        
		while(dut.mav_result.value[0] == 0):
			yield clkedge
        
		dutResultBin = "".join((str(dut.mav_result)))
		modelResultBin = "".join((str(divider_model(A,B,opcode,funct3)))) 
   

		dutResultBin1 = "".join(dutResultBin)
    
#	modelResultBin = divider_model(A,B,divName)    
    
		#dut.RST_N = 1
		#for i in range(5):
		#	yield clkedge
        
		if(modelResultBin != dutResultBin1):
			print("Value from DUT is not and Model are not equal:")
			print("A: ",A)
			print("B: ",B)
			print(modelResultBin,"<========Model========")
			print(dutResultBin1,"<========DUT========")
			raise TestFailure("Incorrect Signed Division result")
		else:
			dut.log.info("Basic Signed Division for random (A/B) Test Passed..") 
        
    

# ------------------------------------Test for unsigned Division------------------------------------------------------

