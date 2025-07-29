`timescale  1ns/1ns
module tb_vga_rom_pic();

	wire hsync;
	wire [15:0] rgb;
	wire vsync;
	
	reg sys_clk;
	reg sys_rst_n;
	
	initial
		begin
			sys_clk = 1'b1;
			sys_rst_n <= 1'b0;
			#200
			sys_rst_n <= 1'b1;
		end
	
	always #10 sys_clk = ~sys_clk  ;
	
	wire [15:0] pix_data = vga_rom_pic_inst.vga_pic_inst.pix_data;
	wire rd_en = vga_rom_pic_inst.vga_pic_inst.rd_en;      
	wire [13:0] rom_addr = vga_rom_pic_inst.vga_pic_inst.rom_addr;
	wire pic_valid = vga_rom_pic_inst.vga_pic_inst.pic_valid;
	wire [15:0] pic_data = vga_rom_pic_inst.vga_pic_inst.pic_data;
	wire vga_clk = vga_rom_pic_inst.vga_pic_inst.vga_clk;
	wire [9:0] pix_x = vga_rom_pic_inst.vga_pic_inst.pix_x;
	wire [9:0] pix_y = vga_rom_pic_inst.vga_pic_inst.pix_y;
	wire [15:0] pix_data_out = vga_rom_pic_inst.vga_pic_inst.pix_data_out;
	
	vga_rom_pic vga_rom_pic_inst(
		.sys_clk (sys_clk),
		.sys_rst_n (sys_rst_n),
	
		.hsync (hsync),
		.vsync (vsync),
		.rgb (rgb)
	);
	
endmodule

