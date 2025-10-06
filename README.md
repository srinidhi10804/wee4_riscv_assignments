# week4_riscv_assignments
Non-Restoring Divider

Overview
This work implements a Non-Restoring Division Algorithm in Bluespec SystemVerilog (BSV). The divider supports both signed and unsigned division for 32-bit and 64-bit data widths.

The design focuses on:
A straightforward iterative Non-Restoring division algorithm.
Handling signed and unsigned division cases.
Managing corner cases like division by zero and equal dividend/divisor.
Providing both quotient and remainder outputs.
Support for control signals such as flush to abort ongoing division.

Modules

mk_non_restoring_divider
Core module implementing the Non-Restoring division algorithm.
Performs one division iteration per clock cycle.
Handles sign management, partial remainder update, quotient bit generation.
Implements special case checks and flush control.

mk_non_restoring_divider_top
Top-level wrapper module for clean external interfacing.
Instantiates the core division module.
Provides methods to start the division, get results, and flush current operation.

Features

Supports 32-bit and 64-bit division based on opcode.
Works for both signed and unsigned division.
Detects and handles division by zero gracefully.
Outputs both quotient and remainder.
Flush operation to cancel ongoing division cleanly.

Usage

Call the start_division method with dividend, divisor, opcode, and funct3 parameters to begin.
Poll the get_result method to check completion and retrieve quotient/remainder.
Use the set_flush method to abort an ongoing division if necessary.

SRT Radix-2 Divider
Overview
This work implements an SRT Radix-2 Divider in Bluespec SystemVerilog (BSV).
The divider performs signed and unsigned division operations on 32-bit operands.
The design includes:
A sequential SRT Radix-2 division algorithm that generates one quotient bit per iteration.
Handling of special cases such as division by zero, negative operands, and equal dividend and divisor.
Support for both quotient and remainder outputs.
Flush control to abort ongoing division operations when required.

Modules
mksrtdiv
Core division module implementing the SRT Radix-2 algorithm.
Performs one division iteration per clock cycle.
Uses partial remainder recurrence and quotient digit selection logic.
Handles sign extension for signed division.
Manages quotient, remainder, and iteration count internally.
Implements special case handling for division by zero and negative values.
Provides flush operation to terminate division in progress.

mkSRTDivider
Wrapper module providing the top-level interface for the divider.
Instantiates the mksrtdiv core module.
Offers methods to start and monitor division operations.
Provides a simplified interface for integration with external systems.

Includes methods for:
Starting division (ma_start).
Retrieving results (mav_result).
Setting flush signals (ma_set_flush).

Features
Supports 32-bit signed and unsigned division.
Implements SRT Radix-2 algorithm with iterative quotient generation.
Handles division by zero and corner cases effectively.
Provides both quotient and remainder outputs.
Includes flush control to cancel ongoing operations safely.
Modular design enables easy extension to higher radices or bit-widths.

Usage
Use the ma_start method to initiate division with parameters:
dividend
divisor
opcode (to specify signed or unsigned operation)
Use the mav_result method to check if the division is complete and to retrieve the quotient and remainder.
Use the ma_set_flush method to flush or cancel the division operation when needed.

SRT Radix-4 Divider
Overview
This work implements an SRT Radix-4 Divider in Bluespec SystemVerilog (BSV). The divider supports signed and unsigned division operations on both 32-bit and 64-bit data widths.

The design includes:
A high-performance, pipelined SRT Radix-4 division algorithm.
Handling of special cases like division by zero, signed overflow, and equal dividend and divisor.
Support for both quotient and remainder outputs.
Control for flush operation to abort ongoing division.

Modules
mksdivider
Core division module implementing the SRT Radix-4 algorithm.
Performs one division step per clock cycle.
Handles sign extension, normalization, quotient digit selection, and partial remainder calculation.
Implements special case handling and flushing.

mk_srt_radix4_divider
Wrapper module providing the top-level interface for the divider.
Instantiates the mksdivider module.
Methods for starting division, retrieving results, and setting flush signals.

Features
Supports division on 32-bit and 64-bit operands based on opcode.
Supports signed and unsigned division.
Handles division by zero and other corner cases gracefully.
Provides quotient and remainder as output.
Flush operation to cancel ongoing division.

Usage
Use the ma_start method to initiate division with dividend, divisor, opcode, and funct3 parameters.
Use the mav_result method to poll for division completion and retrieve result.
Use the ma_set_flush method to flush/cancel division operations when needed.

Technologies Used
Bluespec SystemVerilog (BSV)
Hardware design and verification methodologies
