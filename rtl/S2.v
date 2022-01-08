`include  "./rtl/S_2mode_2.v"
module S2(clk,
	  rst,
	  updown,
	  S2_done,
	  RB2_RW,
	  RB2_A,
	  RB2_D,
	  RB2_Q,
	  sen,
	  sd);

  input clk,
        rst,
        updown;
  
  output S2_done,
         RB2_RW;
  
  output [2:0] RB2_A;
  
  output [17:0] RB2_D;
  
  input [17:0] RB2_Q;
  
  inout sen,
        sd;

  S_2mode_2 s2(
    .clk(clk),
    .rst(rst),
    .updown(updown),
    .S_done(S2_done),
    .RB_RW(RB2_RW),
    .RB_A(RB2_A),
    .RB_D(RB2_D),   
    .RB_Q(RB2_Q),
    .sen(sen),
    .sd(sd)   
  );

endmodule
