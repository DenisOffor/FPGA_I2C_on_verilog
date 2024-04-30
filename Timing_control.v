module Timing_control
(
	input			i_clk,
	input			i_rst,
	input			i_mode,
	input	[3:0]	i_cmd_state,
		
	output		o_clk_10MHz,
	output		o_clk_mode,
	output		o_T_HD_STA_done,
	output		o_T_HD_DAT_done,
	output		o_T_VD_DAT_done
);
	parameter 	CMD_IDLE 					= 	4'b0000;
	parameter 	CMD_START 					= 	4'b0001;
	parameter 	CMD_RESTART 				= 	4'b0010;
	parameter 	CMD_STOP 					= 	4'b0011;

	parameter		STANDART_MODE					=	1'b0;
	parameter		FAST_MODE						=	1'b1;

	reg				r_mode						=	0;
	
	reg	[5:0]		r_t_HD_STA_counter		=	0;
	wire	[5:0]		w_t_HD_count_goal			=	(r_mode == 0) ? 41 : 7;
	wire 				w_t_HD_STA_done			= 	(r_t_HD_STA_counter == w_t_HD_count_goal);
	assign 			o_T_HD_STA_done			=	w_t_HD_STA_done;
	
	
	reg	[5:0]		r_t_LOW_counter			=	0;
	wire	[5:0]		w_t_LOW_count_goal		=	(r_mode == 0) ? 50 : 14;
	wire 				w_t_LOW_done				= 	(r_t_LOW_counter == w_t_LOW_count_goal);
		
	reg	[5:0]		r_t_HIGH_counter			=	0;
	wire	[5:0]		w_t_HIGH_count_goal		=	(r_mode == 0) ? 50 : 11;
	wire 				w_t_HIGH_done				= 	(r_t_HIGH_counter == w_t_HIGH_count_goal);
		
	reg	[5:0]		r_t_HD_DAT_counter		=	0;
	wire	[5:0]		w_t_HD_DAT_count_goal	=	(r_mode == 0) ? 51 : 2;
	wire 				w_t_HD_DAT_done			= 	(r_t_HD_DAT_counter == w_t_HD_DAT_count_goal);
	assign 			o_T_HD_DAT_done			=	w_t_HD_DAT_done;
	
	reg	[5:0]		r_t_VD_DAT_counter		=	0;
	wire	[5:0]		w_t_VD_DAT_count_goal	=	(r_mode == 0) ? 34 : 9;
	wire 				w_t_VD_DAT_done			= 	(r_t_VD_DAT_counter == w_t_VD_DAT_count_goal);
	assign 			o_T_VD_DAT_done			=	w_t_VD_DAT_done;
	
	reg 	[2:0]		r_counter_10MHz			=	0;
	reg				r_10MHz						=	0;
	assign			o_clk_10MHz					=	r_10MHz;
	
	reg	[6:0]		r_counter_mode				=	0;
	reg				r_clk_mode					=	0;
	assign			o_clk_mode					=	r_clk_mode;
	
	always @(*) begin
		if(i_mode)
			r_mode 		<= STANDART_MODE;
		else
			r_mode		<= FAST_MODE;
	end
	
	
	always @(posedge i_clk) begin
		if(r_counter_10MHz == 4) begin
			r_10MHz				<= 	r_10MHz ^ 1'b1;
			r_counter_10MHz	<=		0;
		end
		else
			r_counter_10MHz 	<=		r_counter_10MHz + 1'b1;
	end

	always @(posedge o_clk_10MHz or posedge i_rst) begin
		if(i_rst) begin
			r_counter_mode <=	0;
			r_clk_mode		<=	0;
		end
		else begin
			r_counter_mode <= r_counter_mode + 1'b1;
			
			if(r_counter_mode == 0)
				r_clk_mode		<=	1'b0;
			else if(w_t_LOW_done)
				r_clk_mode		<=	1'b1;
			else if(w_t_HIGH_done) begin
				r_clk_mode		<=	1'b0;	
				r_counter_mode <= 0;
			end
		end
	end
	
	always @(posedge o_clk_10MHz or posedge i_rst) begin
		if(i_rst) begin
		
		end
		else begin
			case(i_cmd_state) begin
				CMD_IDLE: begin
				
				end
				
				
			end
		end
	end
endmodule
