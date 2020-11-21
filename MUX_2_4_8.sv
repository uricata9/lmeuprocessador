
module mux2Data(

	input select,
	input [31:0] a,b,
	output [31:0] y);
	
	wire [31:0] a_internal, b_internal;


	assign a_internal= a & ~select;
	assign b_internal = b & select;
	assign y = a_internal | b_internal;

endmodule

module mux2RegD(

	input select,
	input[4:0] a,b,
	output [4:0] y);
	
	wire [4:0] a_internal, b_internal;


	assign a_internal= a & ~select;
	assign b_internal = b & select;
	assign y = a_internal | b_internal;

endmodule

module mux2Logic(
	

	input select,
	input[3:0] a,b,
	output [3:0] y);
	
	wire [3:0] a_internal, b_internal;


	assign a_internal= a & ~select;
	assign b_internal = b & select;
	assign y = a_internal | b_internal;
	
endmodule

module mux4Logic(
	
	
	input [1:0] select,
	input [3:0] a,b,c,d,
	output [3:0] y);
	
	wire [3:0] a_internal, b_internal,c_internal,d_internal;


	assign a_internal= a & ~select[0] & ~select[1];
	assign b_internal = b & select[0] & ~select[1];
	assign c_internal= c & ~select[0] & ~select[1];
	assign d_internal = d & select[0] & select[1];
	assign y = a_internal | b_internal | c_internal | d_internal;

endmodule

module mux4Data(
	
		
	
	input [1:0] select,
	input [31:0] a,b,c,d,
	output [31:0] y);
	
	wire [31:0] a_internal, b_internal,c_internal,d_internal;


	assign a_internal= a & ~select[0] & ~select[1];
	assign b_internal = b & select[0] & ~select[1];
	assign c_internal= c & ~select[0] & select[1];
	assign d_internal = d & select[0] & select[1];
	assign y = a_internal | b_internal | c_internal | d_internal;
	
endmodule