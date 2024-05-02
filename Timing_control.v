module Timing_control #(parameter CMD_IDLE = 4'b0000, CMD_START = 4'b0001, CMD_DATA_TRANSFER	= 4'b0010, CMD_RESTART = 4'b0011, CMD_STOP = 4'b0100)
(
	input			i_clk,
	input			i_rst,
	input			i_mode,
	input	[4:0]	i_cmd_state,
		
	output		o_clk_10MHz,
	inout			o_SCL,
	output		o_t_HD_STA_done,
	output		o_t_HD_DAT_done,
	output		o_t_VD_DAT_done
);

	
	////////////////////////////////////////////////////
	//Find out which mode selected//////////////////////
	localparam		STANDART_MODE				=	1'b0;
	localparam 		FAST_MODE					=	1'b1;
	reg				r_mode						=	0;
	////////////////////////////////////////////////////
	////////////////////////////////////////////////////	

			
	////////////////////////////////////////////////////
	//for SCL signal genereate//////////////////////////		
	reg	[6:0]		r_counter_for_SCL			=	0;
	reg				r_counter_for_SCL_en		= 	1'b1;
	reg				r_SCL							=	1'b0;
	wire	[6:0]		w_t_LOW_count_goal		=	(r_mode == 0) ? 7'd25 : 7'd7;	//standart or fast mode (5000 or 1400 ns)
	wire 				w_t_LOW_done				= 	(r_counter_for_SCL == w_t_LOW_count_goal);	
	wire	[6:0]		w_t_HIGH_count_goal		=	(r_mode == 0) ? (7'd24 + w_t_LOW_count_goal) : (7'd5 + w_t_LOW_count_goal);	//standart or fast mode (5000 or 1200 ns)
	wire 				w_t_HIGH_done				= 	(r_counter_for_SCL == w_t_HIGH_count_goal);
	assign			o_SCL							=	r_SCL;
	////////////////////////////////////////////////////
	////////////////////////////////////////////////////	
	
	
	////////////////////////////////////////////////////
	//Timer for t_HD_STA timing/////////////////////////	
	reg	[5:0]		r_t_HD_STA_counter		=	0;
	wire	[5:0]		w_t_HD_count_goal			=	(r_mode == 0) ? 7'd20 : 7'd3;	//standart or fast mode (4200 or 800 ns)
	wire 				w_t_HD_STA_done			= 	(r_t_HD_STA_counter == w_t_HD_count_goal);
	assign 			o_t_HD_STA_done			=	w_t_HD_STA_done;
	////////////////////////////////////////////////////
	////////////////////////////////////////////////////	

	
	////////////////////////////////////////////////////
	//Timer for t_HD_DAT timing/////////////////////////		
	wire	[5:0]		w_t_HD_DAT_count_goal	=	(r_mode == 0) ? 7'd5 : 7'd2;	//standart or fast mode (1000 or 400 ns)
	wire 				w_t_HD_DAT_done			= 	(r_counter_for_SCL == w_t_HD_DAT_count_goal);
	assign 			o_t_HD_DAT_done			=	w_t_HD_DAT_done;
	////////////////////////////////////////////////////
	////////////////////////////////////////////////////	

	
	////////////////////////////////////////////////////
	//Timer for t_VD_DAT timing/////////////////////////		
	reg	[5:0]		r_t_VD_DAT_counter		=	0;
	wire	[5:0]		w_t_VD_DAT_count_goal	=	(r_mode == 0) ? 7'd17 : 7'd4;	//standart or fast mode (3400 or 800 ns)
	wire 				w_t_VD_DAT_done			= 	(r_t_VD_DAT_counter == w_t_VD_DAT_count_goal);
	assign 			o_t_VD_DAT_done			=	w_t_VD_DAT_done;
	////////////////////////////////////////////////////
	////////////////////////////////////////////////////	

	
	////////////////////////////////////////////////////
	//10MHz clk/////////////////////////////////////////	
	reg 	[2:0]		r_counter_for_10MHz		=	0;
	reg				r_10MHz						=	0;
	assign			o_clk_10MHz					=	r_10MHz;
	////////////////////////////////////////////////////
	////////////////////////////////////////////////////	

	
	////////////////////////////////////////////////////
	//Check out which mode selected/////////////////////		
	always @(*) begin
		if(i_mode)
			r_mode 		<= STANDART_MODE;
		else
			r_mode		<= FAST_MODE;
	end
	////////////////////////////////////////////////////
	////////////////////////////////////////////////////		

	
	////////////////////////////////////////////////////
	//Always genereate 10MHz(main clock for FSM in top module)
	always @(posedge i_clk) begin
		if(r_counter_for_10MHz == 5'd4) begin
			r_10MHz					<= 	r_10MHz ^ 1'b1;
			r_counter_for_10MHz	<=		0;
		end
		else
			r_counter_for_10MHz 	<=		r_counter_for_10MHz + 1'b1;
	end
	////////////////////////////////////////////////////
	////////////////////////////////////////////////////		
	
	
	////////////////////////////////////////////////////
	///generate SCL when it needed//////////////////////
	always @(posedge o_clk_10MHz or posedge i_rst or posedge r_counter_for_SCL_en) begin
		if(r_counter_for_SCL_en || i_rst) begin
			r_counter_for_SCL 	<=	0;
			r_SCL						<=	1'bz;
		end
		else begin			
			if(r_counter_for_SCL == 0) begin
				r_SCL					<=	1'b0;
				r_counter_for_SCL 	<= r_counter_for_SCL + 1'b1;
			end
			else if(w_t_LOW_done) begin
				r_SCL					<=	1'bz;
				r_counter_for_SCL 	<= r_counter_for_SCL + 1'b1;
			end
			else if(w_t_HIGH_done) begin
				r_counter_for_SCL <= 0;
			end
			else 
				r_counter_for_SCL 	<= r_counter_for_SCL + 1'b1;
		end
	end
	////////////////////////////////////////////////////
	////////////////////////////////////////////////////		

	////////////////////////////////////////////////////
	//FSM for timing control////////////////////////////	
	always @(posedge o_clk_10MHz or posedge i_rst) begin
		if(i_rst) begin
		
		end
		else begin
			case(i_cmd_state) 
				CMD_IDLE: begin
					r_t_HD_STA_counter		<=		0;
					r_t_VD_DAT_counter		<=		0;
				end
				
				CMD_START: begin
					if(w_t_HD_STA_done) begin
						r_t_HD_STA_counter	<=		0;
						r_counter_for_SCL_en	<=		1'b0;	
					end
					else
						r_t_HD_STA_counter	<=		r_t_HD_STA_counter + 1'b1;
				end
				
				CMD_DATA_TRANSFER: begin
					r_counter_for_SCL_en		<=		1'b0;	
				end
				
				CMD_RESTART: begin
				
				end

				CMD_STOP: begin
				
				end				
			endcase
		end
	end
	////////////////////////////////////////////////////
	////////////////////////////////////////////////////		
	
endmodule
