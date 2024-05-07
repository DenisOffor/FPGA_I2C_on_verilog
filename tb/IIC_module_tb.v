module IIC_module_tb
(

);
	reg	clk 				= 1'b0;
	reg	rst 				= 1'b0;
	reg	start				= 1'b0;
	wire	w_Ready_set_new_byte;
	
	reg	[7:0]	r_ram [3:0];
	reg 	[2:0]	r_iter	= 0;
	wire	[7:0]	w_byte;
	assign		w_byte 	= r_ram[r_iter];
	
	initial begin
		#0			r_iter	<=	0;
		#0			r_ram[1]	<=	8'b10101100;
		#0			r_ram[2]	<=	8'b00110011;
		#0			r_ram[3]	<=	8'b00000000;
		#0			clk 		<=	1'b0;
		#0 		rst 		<=	1'b1;
		#0			start 	<=	1'b0;
		#300000	rst		<=	1'b0;
		#450000	start		<=	1'b1;
		#510000	start		<=	1'b0;
	end
	
	
	always @(*)
		#10000 clk <= ~clk;
	
	always @(posedge w_Ready_set_new_byte) begin
		if(r_iter < 3) begin
			r_iter <= r_iter + 1'b1;
		end
	end
	
	IIC_module	my_IIC_module
	(
		.i_clk(clk),
		.i_rst(rst),
		.i_start(start),
		.i_RW(0),
		.i_mode(1),
				
		.i_W_byte(w_byte),
		.i_amount_of_bytes(3),
		.i_address(7'b0111000),

		.io_SDA(),
		.io_SCL(),
		
		.o_Ready_set_new_byte(w_Ready_set_new_byte),
		.o_R_byte(),
		.o_LED1(),
		.o_LED2(),	
		.o_LED3(),	
		.o_LED4()	
	);	
endmodule