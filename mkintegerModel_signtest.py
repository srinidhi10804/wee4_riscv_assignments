import math
from cocotb.binary import BinaryValue
# undefined1 = str(1111111111111111111111111111111111111111111111111111111111111111)
# undefined2 = str(0000000000000000000000000000000000000000000000000000000000000000)
                 
'''
NOTE: RISC TYPES
typedef enum {
   ADD_1,SUB_2,SLL_3,SLT_4,SLTU,XOR, 		
   SRL,SRA,OR,AND,MUL,MULH,
   MULHSU,MULHU,DIV_14,DIVU_15,REM_16,REMU_17,LUI,AUIPC,
	 NOP
   } ALU_func deriving(Eq,Bits,FShow);

'''
# 18446744073709551599
undefined =  -1#18446744073709551615
#----------------------------------------------------------------------------------------------------
def signed_rem(a,b):    #16
    if(a<0 and b>0):
        quotient = math.ceil(a/b)
    elif (b<0 and a>0):
        quotient = math.ceil(a/b)
    elif(a<0 and b<0):
        quotient = math.floor(a/b) 
    elif(b!=0):
        return(unsigned_rem(a,b))
    
    if(b==0):
        remainder = a
    else:
        remainder = a-(b*quotient)
    remainder = remainder | 2**64
    # print(remainder)
    # print(BinaryValue(value=remainder,n_bits=64,bigEndian=False,binaryRepresentation=1))
    return(BinaryValue(value=remainder,n_bits=65,bigEndian=False,binaryRepresentation=2))


def signed_div(a,b):    #14
    # print('in hex =', hex(a))
    # print("a in model after bit padding",a)
    # print("b in model after bit padding",b)        
    # if(0>a):    
    # 	print("a is negative")
    # else:
    # 	print("a is positive")
    if(b==0):
        quotient = undefined
    elif(a<0 and b>0):
        quotient = math.ceil(a/b)
    elif (b<0 and a>0):
        quotient = math.ceil(a/b)
    else:
        quotient = math.floor(a/b)
    quotient = quotient 
    print(quotient)
    # print(BinaryValue(value=quotient,n_bits=64,bigEndian=False,binaryRepresentation=1))
    abs = (BinaryValue(value=quotient,n_bits=65,bigEndian=False,binaryRepresentation=2))
    print(abs)
    abs = abs |(-1)* 2**64
    print(abs)
    return (BinaryValue(value=abs,n_bits=65,bigEndian=False,binaryRepresentation=2))
#---------------------------------------------------------------------------------------------------
def unsigned_rem(a,b):  #17
    if(b==0):
        remainder = a
    else:
        remainder = (a%b)
    remainder = remainder | 2**64   
    # return (a%b)
    # print(remainder)
    # # print(BinaryValue(value=remainder,n_bits=64,bigEndian=False))
    return(BinaryValue(value=remainder,n_bits=65,bigEndian=False))

def unsigned_div(a,b):  #15
    if(b==0):
        quotient = undefined
    else:
        quotient = math.floor(a/b)
        quotient = quotient | 2**64
    # print(quotient)
    # print(BinaryValue(value=quotient,n_bits=64,bigEndian=False))
    if(quotient==undefined):
        return(BinaryValue(value=quotient,bits=65,bigEndian=False,binaryRepresentation=2))
    else:
        return(BinaryValue(value=quotient,n_bits=65,bigEndian=False))
#----------------------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------------------
def signed_div_32_bit(a,b):    #18
    # print("a in model ",a)
    # print("b in model ",b)        
    # if(0>a):    
    # 	print("a is negative")
    # else:
    # 	print("a is positive")

    # if(0>b):    
    # 	print("b is negative")
    # else:
    # 	print("b is positive")

    if(b==0):
        quotient = undefined
    elif(a<0 and b>0):
        quotient = math.ceil(a/b)
    elif (b<0 and a>0):
        quotient = math.ceil(a/b)
    else:
        quotient = math.floor(a/b)
    quotient = quotient | 2**64
    # print(quotient)
    # print(BinaryValue(value=quotient,n_bits=64,bigEndian=False,binaryRepresentation=1))
    return(BinaryValue(value=quotient,n_bits=65,bigEndian=False,binaryRepresentation=2))

def divider_model(a,b,opcode,funct3):
    
    if(opcode == 12 and funct3 == 5):
        return(unsigned_div(a,b))
    elif(opcode==17):
        return unsigned_rem(a,b)
    elif(opcode==12 and funct3 == 0):
        return signed_div(a,b)
    elif(opcode==16):
        return signed_rem(a,b)
#**********************************************
    if(opcode==19):
        return(unsigned_div(a,b))
    elif(opcode==21):
        return unsigned_rem(a,b)
    elif(opcode==18):
    	# return 0
        return signed_div_32_bit(a,b)
    elif(opcode==20):
        return signed_rem(a,b)
    else:
        print("divName Error..")
        return -87        
        # print(BinaryValue(value=remainder,n_bits=64,bigEndian=False))
        # if(remainder >= 0):
        #     return (BinaryValue(value=remainder,n_bits=64,bigEndian=False))
        # else:
        #     return(BinaryValue(value=remainder,bits=64,bigEndian=False,binaryRepresentation=1))


# print(divider_model(-21,-5,15))
