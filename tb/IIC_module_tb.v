module IIC_module_tb
(

);
	reg	clk 	= 1'b0;
	reg	rst 	= 1'b0;
	reg	start	= 1'b0;
	
	initial begin
		#0			clk 	<=	1'b0;
		#0 		rst 	<=	1'b1;
		#0			start <=	1'b0;
		#100000	rst	<=	1'b0;
		#400000	start	<=	1'b1;
		#500000	start	<=	1'b0;
	end
	
	
	always @(*)
		#10000 clk <= ~clk;
	
	IIC_module	my_IIC_module
	(
		.i_clk(clk),
		.i_rst(rst),
		.i_start(start),
		.i_RW(),
		.i_W_memory(),
		.i_mode(1),
		
		.o_SDA(),
		.o_SCL(),
		
		.o_R_memory(),
		.o_LED1(),
		.o_LED2(),	
		.o_LED3(),	
		.o_LED4()	
	);

endmodule