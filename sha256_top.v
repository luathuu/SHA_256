module sha256_top(input clk,input reset_n,input napdata,input [31:0] data_in,output done,output [255:0] sha256,output valid_out_test);
wire valid_out;
wire [31:0] w0,w1;
assign valid_out_test=valid_out;
  message message_unit (
        .clk(clk),
        .reset_n(reset_n),
		  .napdata(napdata),
		  .valid_out(valid_out),
        .data_in(data_in),
        .w_out0(w0), 	
        .w_out1(w1) 
    );
//----------------------//
 
//----------------------//  
    compression compression_unit (
        .clk(clk),
        .reset_n(reset_n),
		   .valid_out(valid_out),
        .W0_in(w0),      
        .W1_in(w1),    
        .outsha256(sha256),
        .done(done)	
    );

endmodule 