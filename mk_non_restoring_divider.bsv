/*
see LICENSE.iitm

Author : Shalender Kumar
Email id : cs18m050@smail.iitm.ac.in
Details:

--------------------------------------------------------------------------------------------------
*/
package non_restoring_divider;
import UniqueWrappers::*;
//`include "defined_parameter.bsv"
`include "Logger.bsv"
interface Ifc_non_restoring_divider;
	/*doc:method: this method takes two 64 bit numbers as input(dividend and divisor) and one input of type ALU_func(operation type)*/
method Action ma_start(Bit#(64) dividend, Bit#(64) divisor, Bit#(4) opcode, Bit#(3) funct3);
	 /*doc:method: this method will return result. Result is quotient or remainder depends on operation type*/
	method ActionValue#(Tuple2#(Bit#(1),Bit#(64))) mav_result();
	 /*doc:method: method for flush division*/
	method Action ma_set_flush(bit c);
endinterface

(* synthesize *)
(*conflict_free="mav_result,ma_start"*)
(*conflict_free="mav_result,rl_extra"*)
(*conflict_free="mav_result,rl"*)
module mk_non_restoring_divider(Ifc_non_restoring_divider);
	/*doc:reg: register to hold inter stage result*/
	Reg#(Bit#(195)) rg_inter_stage <- mkRegU();
	Reg#(Bit#(65)) rg_dividend <-mkReg(0);
	Reg#(Bit#(65)) rg_divisor <-mkReg(0);
	Reg#(Bit#(65)) rg_A <-mkReg(0);
	/*doc:reg: register for counting cycles*/
	Reg#(Bit#(7)) rg_state <- mkReg(0);
	/*doc:reg: register for sign of remainder, in case of signed division*/
	Reg#(Bit#(1)) rg_rem_sign <-mkReg(0);
	/*doc:reg: register for sign of quotient, in case of signed division*/
	Reg#(Bit#(1)) rg_div_sign <-mkReg(0);
	/*doc:reg: register to dicide final result(quotient or remainder)*/
	Reg#(Bit#(1)) rg_div_rem <- mkReg(0);
	Reg#(Bit#(64)) rg_temp_divisor <- mkReg(0);
	Reg#(Bit#(64)) rg_temp_dividend <- mkReg(0);
	Reg#(Bit#(1)) rg_div_type <- mkReg(0);
	Reg#(Bit#(2)) rg_special_case <- mkReg(0);
	Reg#(Bit#(64)) rg_dividend1<-mkReg(0);

/*doc:func: function for taking 2's compliment of a number */
/*function Bit#(64) fn_compliment2(Bit#(64) lv_input);
	Bit#(64) lv_result = signExtend(1'b1);
	bit lv_carry = 1;
	bit lv_new_carry = 1;
	lv_result = lv_input^lv_result;
	for(Integer i = 0; i < 64; i = i+1) begin
		lv_new_carry = lv_carry;
		lv_carry = lv_result[i]&lv_carry;
		lv_result[i] = lv_result[i]^lv_new_carry;
	end
	return lv_result;
endfunction*/

function Bit#(64) fn_compliment2(Bit#(64) lv_input);
	Bit#(64) lv_result = signExtend(1'b1);
	lv_result = lv_result ^ lv_input;
	lv_result = lv_result + 1;
	return lv_result;
endfunction
/*doc:func: functioon for performing one division step. One call of fn_divide_step performs one iteration of non-restoring division*/
/*function Bit#(195) fn_divide_step (Bit#(195) packed_div);
         Bit#(65) lv_all_zeros  = '0;
         Bit#(65) lv_divisor   = packed_div[194:130];
         Bit#(65) lv_remainder = packed_div[129:65];
         Bit#(65) lv_dividend  = packed_div[64:0];
         Bit#(130) lv_accumulator = 0;


	if(lv_remainder[64] == 1'b1)
	begin
		lv_accumulator = ({lv_remainder,lv_dividend})<<1;
		lv_accumulator = lv_accumulator +  {lv_divisor,lv_all_zeros};
	end
	else
	begin
		lv_accumulator = ({lv_remainder,lv_dividend})<<1;
		lv_accumulator = lv_accumulator  - {lv_divisor,lv_all_zeros};
	end

	if(lv_accumulator[129] == 1'b1)
	begin
		lv_accumulator[0] = 0;
	end
	else
	begin
		lv_accumulator[0] = 1;
	end
//	if(rg_state == 64 && lv_accumulator[129] == 1)
	if(rg_state == 65 && lv_accumulator[129] == 1)
	begin
		lv_accumulator = lv_accumulator + {lv_divisor,lv_all_zeros};
	end
	return {lv_divisor,lv_accumulator};

endfunction
*/
/*doc:rule: this rule calles fn_divide_step function in each clock cycle. After performing division step it updates inter stage register*/
//	Wrapper#(Bit#(195),Bit#(195)) wfn_divide_step <- mkUniqueWrapper(fn_divide_step);
//	rule rl(rg_state>=1 && rg_state<=64);
	rule rl(rg_state>=2 && rg_state<=66);

		Bit#(65) lv_all_zeros  = '0;
		Bit#(65) lv_divisor   = rg_inter_stage[194:130];
		Bit#(65) lv_remainder = rg_inter_stage[129:65];
		Bit#(65) lv_dividend  = rg_inter_stage[64:0];
		Bit#(130) lv_accumulator = 0;


		if(lv_remainder[64] == 1'b1)
		begin
			lv_accumulator = ({lv_remainder,lv_dividend})<<1;
			lv_accumulator = lv_accumulator +  {lv_divisor,lv_all_zeros};
		end
		else
		begin
			lv_accumulator = ({lv_remainder,lv_dividend})<<1;
			lv_accumulator = lv_accumulator  - {lv_divisor,lv_all_zeros};
		end

		if(lv_accumulator[129] == 1'b1)
		begin
			lv_accumulator[0] = 0;
		end
		else
		begin
			lv_accumulator[0] = 1;
		end
/*		if(rg_state == 66 && lv_accumulator[129] == 1)
		begin
			lv_accumulator = lv_accumulator + {lv_divisor,lv_all_zeros};
		end*/
		rg_inter_stage <= {lv_divisor,lv_accumulator};
		rg_state <= rg_state + 1;
//        	let x <- wfn_divide_step.func(rg_inter_stage);
//		rg_inter_stage <= x;
	endrule


rule rl_extra(rg_state ==1);
	Bit#(1) lv_rem_sign = 0;
	Bit#(1) lv_div_sign = 0;
	let lv_div_type = rg_div_type;
	let divisor = rg_temp_divisor;
	let dividend = rg_temp_dividend;
	if(dividend[63] == 1 && lv_div_type == 0)
	begin
//		$display("take complement of dividend");
		lv_rem_sign = 1;
		dividend = fn_compliment2(dividend[63:0]);
		lv_div_sign = lv_div_sign ^ 1;
	end
	if(divisor[63] == 1 && lv_div_type == 0)
	begin
//		$display("take complement of divisor");
		divisor = fn_compliment2(divisor[63:0]);
		lv_div_sign = lv_div_sign ^ 1;
	end
	Bit#(65) lv_all_zeros = '0;
        Bit#(195) lv_packed_div = {1'b0,divisor,lv_all_zeros,1'b0,dividend};
//	rg_divisor <= {1'b0,divisor};
//	rg_dividend <= {1'b0,dividend};
//	rg_A <= 0;
//        let x <- wfn_divide_step.func(lv_packed_div);
//	rg_inter_stage <= x;
	rg_inter_stage <= lv_packed_div;
	rg_state<=rg_state + 1;
	rg_div_sign <= lv_div_sign;
	rg_rem_sign <= lv_rem_sign;
endrule

//method Action ma_start(Bit#(64) dividend, Bit#(64) divisor, ALU_func div_name)if(rg_state==0);
method Action ma_start(Bit#(64) dividend, Bit#(64) divisor, Bit#(4) opcode, Bit#(3) funct3)if(rg_state==0);
		Bit#(1) lv_div_type=0;
		Bit#(1)	lv_div_or_rem=0;
		Bit#(1) lv_rem_sign = 0;
		Bit#(1) lv_div_sign = 0;
		Bit#(1) lv_div_len = 0;
		Bit#(64) lv_caseK = 0;
		Bit#(2) lv_special_case = 0;
		lv_caseK[63] = 1;
/*	case(div_name)
		DIV: begin
			lv_div_type   = 0;
			lv_div_or_rem = 0;
		end
		DIVU: begin
			lv_div_type   = 1;
			lv_div_or_rem = 0;
		end
		REM : begin
			lv_div_type   = 0;
			lv_div_or_rem = 1;
		end
		REMU : begin
			lv_div_type   = 1;
			lv_div_or_rem = 1;
		end
		DIVW: begin
			lv_div_type   = 0;
			lv_div_or_rem = 0;
//			lv_div_len = 1;
		end
		DIVUW: begin
			lv_div_type   = 1;
			lv_div_or_rem = 0;
//			lv_div_len = 1;
		end
		REMW : begin
			lv_div_type   = 0;
			lv_div_or_rem = 1;
//			lv_div_len = 1;
		end
		REMUW : begin
			lv_div_type   = 1;
			lv_div_or_rem = 1;
//			lv_div_len = 1;
		end
 	endcase*/
		lv_div_len = pack(opcode == 'b1110);
		lv_div_or_rem = pack(funct3 == 'b110 || funct3 == 'b111);
		lv_div_type = pack(funct3 == 'b101 || funct3 == 'b111);
	if(lv_div_len == 1)
	begin
		lv_caseK = 'hffffffff80000000;
		if(lv_div_type == 0)
		begin
			dividend = signExtend(dividend[31:0]);
			divisor = signExtend(divisor[31:0]);
		end
		else
		begin
			dividend = zeroExtend(dividend[31:0]);
			divisor = zeroExtend(divisor[31:0]);
		end
	end
		if (divisor =='d0) begin
//			$display("special case divisor is zero");
//			rg_inter_stage[129:0] <= {1'b0,dividend,65'd-1};
//			rg_state <= 67;
			lv_special_case = 1;

		end
		else if(dividend==lv_caseK && divisor== 'd-1 && lv_div_type==0)
		begin

//			$display("special case signed overflow");
//			rg_inter_stage[64:0] <= {1'b0,'d-1};
//			rg_inter_stage[129:0] <= {1'b0,'b0,1'b0,dividend};
//			rg_state <= 67;
			lv_special_case = 2;
		end

			rg_temp_divisor <= divisor;
			rg_temp_dividend <= dividend;
			rg_state <= rg_state + 1;
			rg_div_type <= lv_div_type;
			rg_special_case <= lv_special_case;
			rg_dividend1 <= dividend;

/*		begin
			if(dividend[63] == 1 && lv_div_type == 0)
			begin
				lv_rem_sign = 1;
				dividend = fn_compliment2(dividend[63:0]);
				lv_div_sign = lv_div_sign ^ 1;
			end
			if(divisor[63] == 1 && lv_div_type == 0)
			begin
				divisor = fn_compliment2(divisor[63:0]);
				lv_div_sign = lv_div_sign ^ 1;
			end
			rg_state <= rg_state + 1;
		        Bit#(65) lv_all_zeros = '0;
	        	Bit#(195) lv_packed_div = {1'b0,divisor,lv_all_zeros,1'b0,dividend};
	        	let x <- wfn_divide_step.func(lv_packed_div);
			rg_inter_stage <= x;
		end */

		rg_div_sign <= lv_div_sign;
		rg_rem_sign <= lv_rem_sign;
		rg_div_rem <= lv_div_or_rem;
endmethod
method ActionValue#(Tuple2#(Bit#(1),Bit#(64))) mav_result();
	Bit#(1) lv_valid = pack(rg_state == 67);
	Bit#(64) lv_out = 0;
	if(rg_state == 67)
	begin
		rg_state<=0;
		let lv_rem = rg_inter_stage[129:65];
		if(lv_rem[64] == 1)
			lv_rem = lv_rem + rg_inter_stage[194:130];

		if(rg_special_case ==1)
		begin
			if(rg_div_rem == 1) lv_out = rg_dividend1;
			else lv_out = 'd-1;
		end
		else if(rg_special_case ==2)
		begin
			$display("special case signed overflow");
			if(rg_div_rem == 1) lv_out = 0;
			else lv_out = rg_dividend1;
		end
		else
		begin
			if(rg_div_rem == 1)
			begin
				if(rg_rem_sign == 0)
					lv_out = lv_rem[63:0];
				else begin
					lv_out = fn_compliment2(lv_rem[63:0]);
				end
			end
			else
			begin
				if(rg_div_sign == 0)
					lv_out = rg_inter_stage[63:0];
				else begin
					lv_out = fn_compliment2(rg_inter_stage[63:0]);
				end
			end
		end
	end
	return tuple2(lv_valid,lv_out);
endmethod
method Action ma_set_flush(bit c);
		if(c == 0)
			rg_state<=0;
endmethod

endmodule
//************************************** testbench module *************************************************

module tb_non_restoring_divider();


function Bit#(64) fn_compliment2(Bit#(64) lv_input);
	Bit#(64) lv_result = signExtend(1'b1);
	bit lv_carry = 1;
	bit lv_new_carry = 1;
	lv_result = lv_input^lv_result;
	for(Integer i = 0; i < 64; i = i+1) begin
		lv_new_carry = lv_carry;
		lv_carry = lv_result[i]&lv_carry;
		lv_result[i] = lv_result[i]^lv_new_carry;
	end
	return lv_result;
endfunction



	Ifc_non_restoring_divider ifc_div <- mk_non_restoring_divider();
	Reg#(int) rg_cycle <- mkReg(0);
	Reg#(Bit#(4)) rg_opcode <- mkReg('b1100);
	Reg#(Bit#(3)) rg_funct3 <- mkReg('b100);
	Reg#(Bit#(6)) rg_cnt <- mkReg(0);
	rule rl_cycle;
		rg_cycle <= rg_cycle +1;
//		if(rg_cycle==100)
//			$finish(0);
	endrule
//	rule rl_stage_1(rg_cycle % 2==0);
	rule rl_stage_1;
		Bit#(64) op1 ='hab9436;
		Bit#(64) op2 ='h17ab;
		let c1 = fn_compliment2(op1);
		let c2 = fn_compliment2(op2);
		if(rg_cnt == 0)
		$display("c1 %h,c2 %h",c1,c2);
		Bit#(64) dividend = 0;
		Bit#(64) divisor = 0;
		if(rg_cnt == 0)
		begin
			$display($time,"DIV");
			dividend = op1;
			divisor = op2;
			ifc_div.ma_start(dividend,divisor,rg_opcode,rg_funct3);
			rg_cnt<=rg_cnt+1;
		end
		else if(rg_cnt == 1)
		begin
			dividend = fn_compliment2(op1);
			divisor = op2;
			ifc_div.ma_start(dividend,divisor,rg_opcode,rg_funct3);
			rg_cnt<=rg_cnt+1;
		end
		else if(rg_cnt == 2)
		begin
			dividend = op1;
			divisor = fn_compliment2(op2);
			ifc_div.ma_start(dividend,divisor,rg_opcode,rg_funct3);
			rg_cnt<=rg_cnt+1;
		end
		else if(rg_cnt == 3)
		begin
			dividend = fn_compliment2(op1);
			divisor = fn_compliment2(op2);
			ifc_div.ma_start(dividend,divisor,rg_opcode,rg_funct3);
			rg_cnt<=rg_cnt+1;
			rg_funct3 <= 'b110;
		end
//******************************************************************************************
		else if(rg_cnt == 4)
		begin
			$display($time,"REM");
			dividend = op1;
			divisor = op2;
			ifc_div.ma_start(dividend,divisor,rg_opcode,rg_funct3);
			rg_cnt<=rg_cnt+1;
		end
		else if(rg_cnt == 5)
		begin
			dividend = fn_compliment2(op1);
			divisor = op2;
			ifc_div.ma_start(dividend,divisor,rg_opcode,rg_funct3);
			rg_cnt<=rg_cnt+1;
		end
		else if(rg_cnt == 6)
		begin
			dividend = op1;
			divisor = fn_compliment2(op2);
			ifc_div.ma_start(dividend,divisor,rg_opcode,rg_funct3);
			rg_cnt<=rg_cnt+1;
		end
		else if(rg_cnt == 7)
		begin
			dividend = fn_compliment2(op1);
			divisor = fn_compliment2(op2);
			ifc_div.ma_start(dividend,divisor,rg_opcode,rg_funct3);
			rg_cnt<=rg_cnt+1;
			rg_funct3 <= 'b101;
		end
//******************************************************************************************
		else if(rg_cnt == 8)
		begin
			$display($time,"DIVU");
			dividend = op1;
			divisor = op2;
			ifc_div.ma_start(dividend,divisor,rg_opcode,rg_funct3);
			rg_cnt<=rg_cnt+1;
		end
		else if(rg_cnt == 9)
		begin
			dividend = fn_compliment2(op1);
			divisor = op2;
			ifc_div.ma_start(dividend,divisor,rg_opcode,rg_funct3);
			rg_cnt<=rg_cnt+1;
		end
		else if(rg_cnt == 10)
		begin
			dividend = op1;
			divisor = fn_compliment2(op2);
			ifc_div.ma_start(dividend,divisor,rg_opcode,rg_funct3);
			rg_cnt<=rg_cnt+1;
		end
		else if(rg_cnt == 11)
		begin
			dividend = fn_compliment2(op1);
			divisor = fn_compliment2(op2);
			ifc_div.ma_start(dividend,divisor,rg_opcode,rg_funct3);
			rg_cnt<=rg_cnt+1;
			rg_funct3 <= 'b111;
		end
//******************************************************************************************
		else if(rg_cnt == 12)
		begin
			$display($time,"REMU");
			dividend = op1;
			divisor = op2;
			ifc_div.ma_start(dividend,divisor,rg_opcode,rg_funct3);
			rg_cnt<=rg_cnt+1;
		end
		else if(rg_cnt == 13)
		begin
			dividend = fn_compliment2(op1);
			divisor = op2;
			ifc_div.ma_start(dividend,divisor,rg_opcode,rg_funct3);
			rg_cnt<=rg_cnt+1;
		end
		else if(rg_cnt == 14)
		begin
			dividend = op1;
			divisor = fn_compliment2(op2);
			ifc_div.ma_start(dividend,divisor,rg_opcode,rg_funct3);
			rg_cnt<=rg_cnt+1;
		end
		else if(rg_cnt == 15)
		begin
			dividend = fn_compliment2(op1);
			divisor = fn_compliment2(op2);
			ifc_div.ma_start(dividend,divisor,rg_opcode,rg_funct3);
			rg_cnt<=rg_cnt+1;
//			rg_op <= DIVW;
			rg_opcode <= 'b1110;
			rg_funct3 <= 'b100;

		end
//*****************************************************************************************
		else if(rg_cnt == 16)
		begin
			$display($time,"DIVW");
			dividend = op1;
			divisor = op2;
			ifc_div.ma_start(dividend,divisor,rg_opcode,rg_funct3);
			rg_cnt<=rg_cnt+1;
		end
		else if(rg_cnt == 17)
		begin
			dividend = fn_compliment2(op1);
			divisor = op2;
			ifc_div.ma_start(dividend,divisor,rg_opcode,rg_funct3);
			rg_cnt<=rg_cnt+1;
		end
		else if(rg_cnt == 18)
		begin
			dividend = op1;
			divisor = fn_compliment2(op2);
			ifc_div.ma_start(dividend,divisor,rg_opcode,rg_funct3);
			rg_cnt<=rg_cnt+1;
		end
		else if(rg_cnt == 19)
		begin
			dividend = fn_compliment2(op1);
			divisor = fn_compliment2(op2);
			ifc_div.ma_start(dividend,divisor,rg_opcode,rg_funct3);
			rg_cnt<=rg_cnt+1;
//			rg_op <= REMW;
			rg_funct3 <= 'b110;
		end
//***************************************************************************************
		else if(rg_cnt == 20)
		begin
			$display($time,"REMW");
			dividend = op1;
			divisor = op2;
			ifc_div.ma_start(dividend,divisor,rg_opcode,rg_funct3);
			rg_cnt<=rg_cnt+1;
		end
		else if(rg_cnt == 21)
		begin
			dividend = fn_compliment2(op1);
			divisor = op2;
			ifc_div.ma_start(dividend,divisor,rg_opcode,rg_funct3);
			rg_cnt<=rg_cnt+1;
		end
		else if(rg_cnt == 22)
		begin
			dividend = op1;
			divisor = fn_compliment2(op2);
			ifc_div.ma_start(dividend,divisor,rg_opcode,rg_funct3);
			rg_cnt<=rg_cnt+1;
		end
		else if(rg_cnt == 23)
		begin
			dividend = fn_compliment2(op1);
			divisor = fn_compliment2(op2);
			ifc_div.ma_start(dividend,divisor,rg_opcode,rg_funct3);
			rg_cnt<=rg_cnt+1;
//			rg_op <= DIVUW;
			rg_funct3 <= 'b101;
		end
//**************************************************************************************
		else if(rg_cnt == 24)
		begin
			$display($time,"DIVUW");
			dividend = op1;
			divisor = op2;
			ifc_div.ma_start(dividend,divisor,rg_opcode,rg_funct3);
			rg_cnt<=rg_cnt+1;
		end
		else if(rg_cnt == 25)
		begin
			dividend = fn_compliment2(op1);
			divisor = op2;
			ifc_div.ma_start(dividend,divisor,rg_opcode,rg_funct3);
			rg_cnt<=rg_cnt+1;
		end
		else if(rg_cnt == 26)
		begin
			dividend = op1;
			divisor = fn_compliment2(op2);
			ifc_div.ma_start(dividend,divisor,rg_opcode,rg_funct3);
			rg_cnt<=rg_cnt+1;
		end
		else if(rg_cnt == 27)
		begin
			dividend = fn_compliment2(op1);
			divisor = fn_compliment2(op2);
			ifc_div.ma_start(dividend,divisor,rg_opcode,rg_funct3);
			rg_cnt<=rg_cnt+1;
//			rg_op <= REMUW;
			rg_funct3 <= 'b111;
		end
//*************************************************************************************
		else if(rg_cnt == 28)
		begin
			$display($time,"REMUW");
			dividend = op1;
			divisor = op2;
			ifc_div.ma_start(dividend,divisor,rg_opcode,rg_funct3);
			rg_cnt<=rg_cnt+1;
		end
		else if(rg_cnt == 29)
		begin
			dividend = fn_compliment2(op1);
			divisor = op2;
			ifc_div.ma_start(dividend,divisor,rg_opcode,rg_funct3);
			rg_cnt<=rg_cnt+1;
		end
		else if(rg_cnt == 30)
		begin
			dividend = op1;
			divisor = fn_compliment2(op2);
			ifc_div.ma_start(dividend,divisor,rg_opcode,rg_funct3);
			rg_cnt<=rg_cnt+1;
		end
		else if(rg_cnt == 31)
		begin
			dividend = fn_compliment2(op1);
			divisor = fn_compliment2(op2);
			ifc_div.ma_start(dividend,divisor,rg_opcode,rg_funct3);
			rg_cnt<=rg_cnt+1;
//			rg_op <= DIVW;
		end
		else $finish(0);
//*************************************************************************************
	endrule
	rule rl_receive;
		match {.valid,.out} <- ifc_div.mav_result();
//		`logLevel( tb, 0, $format("Cycle %d => valid %d value %d",rg_cycle,valid,out))
		if(valid == 1)
		$display($time,"Cycle %d => valid %d value %h",rg_cycle,valid,out);
	endrule
endmodule



endpackage
