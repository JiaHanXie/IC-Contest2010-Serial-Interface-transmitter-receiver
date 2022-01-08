module S_2mode_1
(
	clk,
	rst,
	updown,
	S_done,
	RB_RW,
	RB_A,
	RB_D,
	RB_Q,
	sen,
	sd
);
//
	localparam	Wait_state			=	3'd0;
	localparam	Send_state			=	3'd1;
	localparam	Send_Addr_Up_state	=	3'd2;
	localparam	Finish_Send_state	=	3'd3;
	localparam	Recv_state			=	3'd4;
	localparam	Recv_Write_state	=	3'd5;
	localparam	Finish_Recv_state	=	3'd6;
	localparam	Init_state			=	3'd7;
//
	localparam	BIT_RB_A=5;
	localparam	BIT_RB_D=8;
	localparam	SendRecv=1'b0;//Send:0 ; Recv:1
//
	localparam	Count4send=21;
	localparam	Count4column=8;
	localparam	Count4recv=13;
	localparam	Count4row=18;
	localparam	BIT_Count4send=5;
	localparam	BIT_Count4column=3;
	localparam	BIT_Count4recv=4;
	localparam	BIT_Count4row=5;
	localparam	BIT_REG=13;
//port
	input								clk;
	input								rst;
	input								updown;
	output	reg							S_done;
	output	reg							RB_RW;//0: W; 1:R
	output	reg		[BIT_RB_A-1:0]		RB_A;
	output	reg		[BIT_RB_D-1:0]		RB_D;
	input			[BIT_RB_D-1:0]		RB_Q;
	inout								sen;//0: valid
	inout								sd;
//net
	wire								sen_in;
	reg									sen_in_1;
	reg									sen_out,sen_out_1;
	wire								sd_in;
	reg									sd_in_1;
	reg									sd_out,sd_out_1;
	reg									RB_RW_plam;//0: W; 1:R
	reg				[BIT_RB_A-1:0]		RB_A_plam;
	reg				[BIT_RB_D-1:0]		RB_D_plam;
	reg									updown_plam;
	reg									en4tri_out;
	reg									en4tri_in;
//
	reg		[2:0]						FSM,next_FSM;
	reg		[BIT_Count4send-1:0]		Counter_send,next_Counter_send;//count down
	reg		[BIT_Count4column-1:0]		Counter_column,next_Counter_column;
	reg		[BIT_Count4recv-1:0]		Counter_recv,next_Counter_recv;
	reg		[BIT_Count4row-1:0]			Counter_row,next_Counter_row;
	reg		[BIT_REG-1:0]				REG,next_REG;
//tristate
	assign	sd=(updown==SendRecv)? sd_out:'bz;
	assign	sd_in=(updown==~SendRecv)? sd:'bz;
	assign	sen=(updown==SendRecv)? sen_out:'bz;
	assign	sen_in=(updown==~SendRecv)? sen:'bz;

//updown_plam
	
	always @(negedge clk or posedge rst) begin
		if(rst) begin
			updown_plam <= 'd0;
		end else begin
			updown_plam <= updown;
		end
	end
	/*
	always @(*) begin
		if (FSM!=Wait_state) begin
			en4tri_out=(updown==SendRecv);
		end
		else begin
			en4tri_out=1'b0;
		end
	end
	always @(*) begin
		if (FSM!=Wait_state) begin
			en4tri_in=(updown==~SendRecv);
		end
		else begin
			en4tri_in=1'b0;
		end
	end
	*/
//FSM
	always @(negedge clk or posedge rst) begin
		if(rst) begin
			FSM <= 'd0;
		end else begin
			FSM <= next_FSM;
		end
	end
//next_FSM
	always @(*) begin
		case (FSM)
			Wait_state:begin
				next_FSM=(updown_plam==SendRecv)?Init_state:Recv_state;
			end
			Init_state:begin
				next_FSM=Send_state;
			end
			Send_state:begin
				next_FSM=((Counter_column==(Count4column-1))&&(Counter_send=='d0))?Finish_Send_state:
				((Counter_send=='d0)?Send_Addr_Up_state:Send_state);
			end
			Send_Addr_Up_state:begin
				next_FSM=Send_state;
			end
			Finish_Send_state:begin
				next_FSM=(updown_plam==~SendRecv)?Recv_state:Finish_Send_state;
			end
			Recv_state:begin
				next_FSM=(Counter_recv==(Count4recv-1))?Recv_Write_state:Recv_state;
			end
			Recv_Write_state:begin
				next_FSM=(Counter_row==(Count4row-1))?Finish_Recv_state:Recv_state;
			end
			Finish_Recv_state:begin
				next_FSM=(updown_plam==SendRecv)?Init_state:Finish_Recv_state;
			end
			default:begin
				next_FSM=FSM;
			end
		endcase
	end
//Counter_send
	always @(negedge clk or posedge rst) begin
		if(rst) begin
			Counter_send <= (Count4send-1);
		end else if(FSM==Send_state) begin
			Counter_send <= next_Counter_send;
		end
		else if ((FSM==Finish_Recv_state)||(FSM==Send_Addr_Up_state)) begin
			Counter_send <= (Count4send-1);
		end
	end
//
	always @(*) begin
		if (Counter_send=='d0) begin
			next_Counter_send=Counter_send;
		end
		else begin
			next_Counter_send=Counter_send-1'd1;
		end
	end
//Counter_column
	always @(negedge clk or posedge rst) begin
		if(rst) begin
			Counter_column <= 'd0;
		end else if(FSM==Send_Addr_Up_state) begin
			Counter_column <= next_Counter_column;
		end
		else if (FSM==Finish_Recv_state) begin
			Counter_column <= 'd0;
		end
	end
//
	always @(*) begin
		if (Counter_column==(Count4column-1)) begin
			next_Counter_column=Counter_column;
		end
		else begin
			next_Counter_column=Counter_column+1'd1;
		end
	end
//Counter_recv
	always @(negedge clk or posedge rst) begin
		if(rst) begin
			Counter_recv <= 'd0;
		end 
		else if(FSM==Recv_state) begin
			Counter_recv <= next_Counter_recv;
		end
		else if (FSM==Recv_Write_state) begin
			Counter_recv <= 'd0;
		end
	end
//
	always @(*) begin
		if (Counter_recv==(Count4recv-1)) begin
			next_Counter_recv=Counter_recv;
		end
		else if(sen_in_1==1'b0) begin
			next_Counter_recv=Counter_recv+1'd1;
		end
		else begin
			next_Counter_recv=Counter_recv;
		end
	end
//Counter_row
	always @(negedge clk or posedge rst) begin
		if(rst) begin
			Counter_row <= 'd0;
		end else if(FSM==Recv_Write_state) begin
			Counter_row <= next_Counter_row;
		end
		else if (FSM==Finish_Send_state) begin
			Counter_row <= 'd0;
		end
	end
//
	always @(*) begin
		if (Counter_row==(Count4row-1)) begin
			next_Counter_row=Counter_row;
		end
		else begin
			next_Counter_row=Counter_row+1'd1;
		end
	end
//REG
	always @(negedge clk or posedge rst) begin
		if(rst) begin
			REG <= 0;
		end else if((FSM==Send_state)||(FSM==Recv_state)) begin
			REG <= next_REG;
		end
	end
//
	always @(*) begin
		case (FSM)
			Send_state:begin
				next_REG={{(BIT_REG-BIT_RB_D){1'b0}},RB_Q};
			end
			Recv_state:begin
				if (sen_in_1==1'b0) begin
					next_REG={REG[BIT_REG-2:0],sd_in_1};
				end
				else begin
					next_REG=REG;
				end
			end
			default:begin
				next_REG=REG;
			end
		endcase
	end
//sen_out
	always @(*) begin
		if (FSM==Send_state) begin
			sen_out_1=1'b0;
		end
		else begin
			sen_out_1=1'b1;
		end
	end
//sd_out
	always @(*) begin
		if (Counter_send>=Count4row) begin
			sd_out_1=Counter_column[Counter_send-Count4row];
		end
		else begin
			sd_out_1=REG[Count4column-Counter_column-1];
		end
	end
//S_done
	always @(negedge clk or posedge rst) begin
		if(rst) begin
			S_done <= 1'b0;
		end else if(FSM==Finish_Recv_state) begin
			S_done <= 1'b1;
		end
		else if (updown_plam==SendRecv) begin
			S_done <= 1'b0;
		end
	end
//RB_RW//0: W; 1:R
	always @(*) begin
		if (FSM==Recv_Write_state) begin
			RB_RW_plam=1'b0;
		end
		else begin
			RB_RW_plam=1'b1;
		end
	end
	always @(negedge clk or posedge rst) begin
		if (rst) begin
			RB_RW <= 1'b1;
		end
		else begin
			RB_RW <= RB_RW_plam;
		end
	end
//RB_A
	always @(*) begin
		case (FSM)
			Send_state:begin
				if (((Counter_send-2'd2)<Count4row)&&(Counter_send>'d1)) begin
					RB_A_plam=Counter_send-2'd2;
				end
				else begin
					RB_A_plam='d0;
				end
			end
			Recv_Write_state:begin
				RB_A_plam=REG[BIT_REG-1:BIT_REG-BIT_Count4row];
			end
			default:begin
				RB_A_plam='d0;
			end
		endcase
	end
	always @(negedge clk or posedge rst) begin
		if (rst) begin
			RB_A <= 'd0;
		end
		else begin
			RB_A <= RB_A_plam;
		end
	end
//RB_D
	always @(*) begin
		RB_D_plam=REG[BIT_RB_D-1:0];
	end
	always @(negedge clk or posedge rst) begin
		if (rst) begin
			RB_D <= 0;
		end
		else begin
			RB_D <= RB_D_plam;
		end
	end
//
	always @(negedge clk or posedge rst) begin
		if(rst) begin
			sen_in_1 <= 0;
		end else begin
			sen_in_1 <= sen_in;
		end
	end
//
	always @(negedge clk or posedge rst) begin
		if(rst) begin
			sen_out <= 0;
		end else begin
			sen_out <= sen_out_1;
		end
	end
//sd_in_1
	always @(negedge clk or posedge rst) begin
		if(rst) begin
			sd_in_1 <= 0;
		end else begin
			sd_in_1 <= sd_in;
		end
	end
//sd_out
	always @(negedge clk or posedge rst) begin
		if(rst) begin
			sd_out <= 0;
		end else begin
			sd_out <= sd_out_1;
		end
	end
endmodule