module IIC_module
(
	input 				i_clk,
	input 				i_rst,
	input 				i_start,
	input					i_RW,
	input		[7:0]		i_W_memory,
	input					i_mode,
	
	inout					o_SDA,
	inout 				o_SCL,
	
	output	[7:0]		o_R_memory,
	output				o_LED1,
	output				o_LED2,	
	output				o_LED3,	
	output				o_LED4	
);
	////////////////////////////////////////////////////
	//FSM states////////////////////////////////////////
	parameter 		CMD_IDLE 				= 	4'b0000;
	parameter 		CMD_START 				= 	4'b0001;
	parameter 		CMD_DATA_TRANSFER 	= 	4'b0010;
	parameter 		CMD_RESTART 			= 	4'b0011;
	parameter 		CMD_STOP 				= 	4'b0100;
	
	//parameter 	CMD_STOP 				= 	4'b0011;
	//parameter 	CMD_STOP 				= 	4'b0011;	
	reg	[4:0]		r_CMD_state				=	CMD_IDLE;
	////////////////////////////////////////////////////
	////////////////////////////////////////////////////
	/**/
	/**/
	////////////////////////////////////////////////////
	////////////////////////////////////////////////////	
	reg 				r_SDA						= 	1'bz;
	assign			o_SDA						= 	r_SDA;
	reg	[7:0]		r_R_memory				=	0;
	////////////////////////////////////////////////////
	////////////////////////////////////////////////////
	/**/
	/**/
	////////////////////////////////////////////////////
	//wires for TIMINg_control module///////////////////
	wire	[4:0]		w_cmd_state;	
	wire				w_clk_10MHz;
	wire				w_t_HD_STA_done;
	wire				w_t_HD_DAT_done;
	wire				w_t_VD_DAT_done;
	assign 			w_cmd_state				=	r_CMD_state;
	////////////////////////////////////////////////////
	////////////////////////////////////////////////////	
	/**/	
	/**/
	////////////////////////////////////////////////////
	//FOR CHECKCOUT/////////////////////////////////////
	reg 				r_LED1					=	1'b1;
	reg 				r_LED2					=	1'b1;
	reg 				r_LED3					=	1'b1;
	reg 				r_LED4					=	1'b1;
	
	assign			o_LED1					=	r_LED1;
	assign			o_LED2					=	r_LED2;
	assign			o_LED3					=	r_LED3;
	assign			o_LED4					=	r_LED4;
	////////////////////////////////////////////////////
	////////////////////////////////////////////////////
	/**/
	/**/	
	
	//debug
	wire 	[7:0]		w_test_data				=	8'b00101110;
	reg	[2:0]		r_iter					=	0;
	
	always @(posedge w_clk_10MHz or posedge i_rst) begin
		if(i_rst) begin
			r_CMD_state					<= CMD_IDLE;
			r_SDA							<=	1'bz;
			r_R_memory					<= 0;
		end
		else begin
			case(r_CMD_state)
				CMD_IDLE: begin
					r_SDA					<=	1'bz;
					if(i_start)	begin
						//if(o_SDA == 1'bz && o_SCL == 1'bz) begin//1 1
							r_CMD_state <=	CMD_START;		
							r_LED1		<= 1'b1;
						//end	
						//else
						//	r_LED1		<= 1'b0;
					end
				end
			
				CMD_START: begin
					r_SDA					<=	1'b0;
					if(w_t_HD_STA_done) begin
						r_CMD_state <=	CMD_DATA_TRANSFER;
					end
				end
				
				CMD_DATA_TRANSFER: begin
					if(w_t_HD_DAT_done) begin
						r_SDA				<=	w_test_data[r_iter];
						r_iter			<=	r_iter + 1'b1;	
					end
				end
				
				CMD_RESTART: begin
				
				end
				
			endcase
		end
	end
	
	Timing_control #(.CMD_IDLE(CMD_IDLE), .CMD_START(CMD_START) , .CMD_DATA_TRANSFER(CMD_DATA_TRANSFER), .CMD_RESTART(CMD_RESTART), .CMD_STOP(CMD_STOP)) my_Timing_control
	(
		.i_clk(i_clk),
		.i_rst(i_rst),
		.i_mode(i_mode),
		.i_cmd_state(w_cmd_state),
		
		.o_clk_10MHz(w_clk_10MHz),
		.o_SCL(o_SCL),
		.o_t_HD_STA_done(w_t_HD_STA_done),
		.o_t_HD_DAT_done(w_t_HD_DAT_done),
		.o_t_VD_DAT_done(w_t_VD_DAT_done)
	);

endmodule