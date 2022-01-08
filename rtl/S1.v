`include  "./rtl/S_2mode_1.v"
module S1(clk,
	  rst,
	  updown,
	  S1_done,
	  RB1_RW,
	  RB1_A,
	  RB1_D,
	  RB1_Q,
	  sen,
	  sd);

  input clk,
        rst,
        updown;

  output S1_done,
         RB1_RW;
  
  output [4:0] RB1_A;
  
  output [7:0] RB1_D;
  
  input [7:0] RB1_Q;
  
  inout sen,
        sd;

  S_2mode_1 s1(
    .clk(clk),
    .rst(rst),
    .updown(updown),
    .S_done(S1_done),
    .RB_RW(RB1_RW),
    .RB_A(RB1_A),
    .RB_D(RB1_D),   
    .RB_Q(RB1_Q),
    .sen(sen),
    .sd(sd)   
  );
  
endmodule
