`include "./rtl/S1.v"
`include "./rtl/S2.v"
module S
(
	input					clk,
	input					rst,
	input					updown,
	output	wire			S1_done,
	output	wire			sen,
	output	wire			sd,
	output	wire			S2_done,
	output	wire			RB1_RW,
	output	wire	[4:0]	RB1_A,
	output	wire	[7:0]	RB1_D,
	input			[7:0]	RB1_Q,
	output	wire			RB2_RW,
	output	wire	[2:0]	RB2_A,
	output	wire	[17:0]	RB2_D,
	input			[17:0]	RB2_Q
	);

	S1 S1(
	.clk(clk),
	.rst(rst),
	.updown(updown),
	.S1_done(S1_done),
	.RB1_RW(RB1_RW),
	.RB1_A(RB1_A),
	.RB1_D(RB1_D),
	.RB1_Q(RB1_Q),
	.sen(sen),
	.sd(sd)
	);

	S2 S2(
	.clk(clk),
	.rst(rst),
	.updown(updown),
	.S2_done(S2_done),
	.RB2_RW(RB2_RW),
	.RB2_A(RB2_A),
	.RB2_D(RB2_D),
	.RB2_Q(RB2_Q),
	.sen(sen),
	.sd(sd)
	);

endmodule