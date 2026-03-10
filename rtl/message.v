module message(input clk,
input reset_n,
input napdata,
input [31:0] data_in,
output reg valid_out,
output reg [31:0] w_out0,
output reg [31:0] w_out1 );
// xay dung datapath 
// |----------------------------------------------------------------|
// |                                                                |
// |                                                                |
// |----------------------------------------------------------------|
reg [31:0] w [15:0];
reg [5:0] t;
reg [5:0] y;
// sigma0
   function [31:0] s0(input [31:0] x);
	begin
   s0=ROTR(x,7)^ROTR(x,18)^SHR(x,3);
   end
	endfunction
//sigma1
   function [31:0] s1(input [31:0] x);
	begin
	s1=ROTR(x,17)^ROTR(x,19)^SHR(x,10);
   end
	endfunction
// Hàm xoay phải (Rotate Right)
    function [31:0] ROTR (input [31:0] x, input integer n);
       begin      
		ROTR = (x >> n) | (x << (32 - n));
       end
	 endfunction
// Hàm dịch phải (Shift Right)
    function [31:0] SHR (input [31:0] x, input integer n);
	 begin
        SHR = (x >> n);
	end
    endfunction
// gia tri cap nhat cho 2 thanh ghi
wire [31:0] w_ss0;
wire [31:0] w_ss1;
assign w_ss0=s1(w[(2*t+14)%16])+w[(2*t+9)%16]+s0(w[2*t%16+1])+w[2*t%16];
assign w_ss1=s1(w[(2*t+15)%16])+w[(2*t+10)%16]+s0(w[(2*t+2)%16])+w[2*t%16+1];
// xay dung datapath 
// |----------------------------------------------------------------|
// |                                                                |
// |                                                                |
// |----------------------------------------------------------------|
// 1. Định nghĩa các trạng thái
localparam [1:0] IDLE   = 2'b00; // Chờ
localparam [1:0] LOAD   = 2'b01; // Nạp dữ liệu
localparam [1:0] T1_PROCESS = 2'b10; // Tính toán (t <= 24)
localparam [1:0] T2_PROCESS = 2'b11; // Chỉ xuất output (t > 24)
// 2. Thanh ghi trạng thái
reg [1:0] state, next_state;
always@* begin 
  next_state= state;
      case(state)
	       	IDLE : begin 
				       if(napdata) 
						 next_state=LOAD;
						 else 
						 next_state=IDLE;
						 end 
		      LOAD : begin 
				       if(y==15) 
						 next_state= T1_PROCESS;
						 else 
						 next_state= LOAD;
						 end 
				T1_PROCESS : begin 
				        if(t==25)
						  next_state=T2_PROCESS;
						  else if(t<25)
						  next_state=T1_PROCESS;
						  end
				T2_PROCESS : begin 
			           if(t==32) begin
						  next_state=IDLE; end
						  else next_state=T2_PROCESS;
                         end 								 	
		           default: next_state=IDLE;
		       endcase 
		end 	
always@(posedge clk or negedge reset_n)
begin 
   if(!reset_n)
	 state <= IDLE;
	else 
	 state <= next_state;
end 		
always@(posedge clk or negedge reset_n) 
begin
     if(!reset_n) 
	  begin 
           w[0]  <= 0;
           w[1]  <= 0;
           w[2]  <= 0;
           w[3]  <= 0;
           w[4]  <= 0;
           w[5]  <= 0;
           w[6]  <= 0;
           w[7]  <= 0;
           w[8]  <= 0;
           w[9]  <= 0;
           w[10] <= 0;
           w[11] <= 0;
           w[12] <= 0;
           w[13] <= 0;
           w[14] <= 0;
           w[15] <= 0;
	        w_out0<=0;
	        w_out1<=0;
	        y<=0;
	        t<=0;
	        valid_out<=0;
	    end 
	else begin 
	    case(state)
	       IDLE: begin 	t<=0;   y<=0;  w_out0 <= 0; w_out1 <= 0; end 
		    LOAD: begin
                case (y[3:0])
                    4'd0:  w[0]  <= data_in;
                    4'd1:  w[1]  <= data_in;
                    4'd2:  w[2]  <= data_in;
                    4'd3:  w[3]  <= data_in;
                    4'd4:  w[4]  <= data_in;
                    4'd5:  w[5]  <= data_in;
                    4'd6:  w[6]  <= data_in;
                    4'd7:  w[7]  <= data_in;
                    4'd8:  w[8]  <= data_in;
                    4'd9:  w[9]  <= data_in;
                    4'd10: w[10] <= data_in;
                    4'd11: w[11] <= data_in;
                    4'd12: w[12] <= data_in;
                    4'd13: w[13] <= data_in;
                    4'd14: w[14] <= data_in;
                    4'd15: w[15] <= data_in;
                endcase
                y <= y + 1;
                if (y == 15) valid_out <= 1;
            end
		  T1_PROCESS :
	        begin
		      w[2*t%16]<=w_ss0;
				w[2*t%16+1]<=w_ss1;
	         w_out0<=w[2*t%16];
	         w_out1<=w[2*t%16+1];	 
	         t<=t+1;
				valid_out<=0;
    	      end
	     T2_PROCESS:
	         begin 
	     w_out0<=w[2*t%16];
	     w_out1<=w[2*t%16+1];
	     t<=t+1;
	         end
		 endcase 
end
end
endmodule