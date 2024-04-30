module IIC_module
(
	input 				i_clk,
	input 				i_rst,
	input 				i_start,
	input					i_RW,
	input		[7:0]		i_W_memory,
	input					i_mode,
	
	output	[7:0]		o_R_memory,
	inout					o_SDA,
	output 				o_SCL
);
	parameter 	CMD_IDLE 					= 	4'b0000;
	parameter 	CMD_START 					= 	4'b0001;
	parameter 	CMD_RESTART 				= 	4'b0010;
	parameter 	CMD_STOP 					= 	4'b0011;
				
	//parameter CMD_STOP 					= 	4'b0011;
	//parameter CMD_STOP 					= 	4'b0011;
	//parameter CMD_STOP 					= 	4'b0011;
	
	reg	[4:0]		r_CMD_state				=	CMD_IDLE;
	reg 				r_SDA						= 	1'bz;
	reg				r_SCL						=	1'bz;
	
	reg	[7:0]		r_R_memory				=	0;
	
	assign			o_SDA						= 	r_SDA;
	assign			o_SCL						= 	r_SCL;
	
	
	
	always @(posedge i_clk or posedge i_rst) begin
		if(i_rst) begin
			r_CMD_state					<= CMD_IDLE;
			r_SDA							<=	1'bz;
			r_SCL							<=	1'bz;
			r_R_memory					<= 0;
		end
		else begin
			case(r_CMD_state)
				CMD_IDLE: begin
					r_SDA					<=	1'bz;
					r_SCL					<=	1'bz;
					if(i_start)	begin
						if(o_SDA == 1'bz && o_SCL == 1'bz) //1 1
							r_CMD_state <=	CMD_START;						
					end
				end
			
				CMD_START: begin
					r_SDA					<=	1'b0;
					r_SCL					<=	1'bz;
					//if() begin
					//	r_SCL					<=	1'b0;
					//end
				end
				
				CMD_RESTART: begin
				
				end
				
			endcase
		end
	end
	

endmodule