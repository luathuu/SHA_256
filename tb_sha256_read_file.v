`timescale 1ns / 1ps

module tb_sha256_read_file;

   
    localparam CLK_PERIOD = 20;
    reg clk;
    reg reset_n;
    reg napdata;
    reg [31:0] data_in;
      integer k=0;
    wire done;
	 wire  valid_out_test;
    wire [255:0] sha256;
    reg [511:0] block_in;
    reg [255:0] expected_hash;
    integer errors;
    integer file_handle;      // Biến quản lý file
    integer scan_status;      // Biến kiểm tra lỗi đọc
    reg [31:0] num_blocks;    // Số lượng block
    integer i;                // Biến chạy vòng lặp
    sha256_top uut (
        .clk(clk),
        .reset_n(reset_n),
        .napdata(napdata),
        .data_in(data_in),
        .done(done),
		  .valid_out_test(valid_out_test),
        .sha256(sha256)
    );
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    task reset_dut;
    begin
        reset_n = 1'b0; 
        napdata = 0;
        data_in = 32'b0;
        #(CLK_PERIOD * 2); 
        reset_n = 1'b1; 
        #(CLK_PERIOD);
    end
    endtask
    // --- Tạo Clock ---
  
 task load_block;
        input [511:0] block;      
        input [255:0] expected;
        input is_final_block;     
        integer i;
    begin
	         @(negedge clk);
				  napdata = 1;
				 @(posedge clk);
        for (i = 0; i < 16; i = i + 1) begin	

            data_in = block >> (32 * (15 - i));
				@(posedge clk);
            
        end
		    @(posedge clk);
            napdata = 1'b0;
            data_in = 32'b0;

        while (!done) begin
            @(posedge clk);
        end
        if (is_final_block) begin
            if (sha256 != expected) begin
                $display("!!! ERROR: Test Case FAILED. (Time: %0t)", $time);
                $display("    Expected: %h", expected);
                $display("    Actual:   %h", sha256);
                errors = errors + 1;
            end else begin
                $display("--- SUCCESS: Test Case Passed. (Time: %0t)", $time);
                $display("    Hash: %h", sha256);
            end
        end
        @(posedge clk);
    end
    endtask
    // --- Luồng xử lý chính ---
    initial begin
        // 1. Khởi tạo
        block_in = 0;
        reset_dut();
        // 2. Mở file vectors.hex 
        file_handle = $fopen("vectors.hex", "r");
        if (file_handle == 0) begin
            $display("ERROR: Khong tim thay file vectors.hex");
            $finish;
        end
        // 3. Đọc HEADER 
        scan_status = $fscanf(file_handle, "%h\n", num_blocks);
        $display("----------------------------------------");
        $display("Testbench Start: Tim thay %0d blocks can xu ly", num_blocks);
		  // Đọc dòng 2: kết quả mong đợi
        scan_status = $fscanf(file_handle, "%h\n", expected_hash);
		  $display("Ket qua mong doi %h", expected_hash);
        #20;
        // 4. Vòng lặp nạp từng block
        for (i = 0; i < num_blocks; i = i + 1) begin
            // Đọc dòng dữ liệu hex 512-bit
            scan_status = $fscanf(file_handle, "%h\n", block_in);
            
            $display("-> Dang nap Block %0d vao module...", i);
				$display("block ...", block_in);
				if(i== num_blocks-1)
				begin
				k=1;
				end 
				load_block(block_in, expected_hash,k);
        end        
        $fclose(file_handle);
        $finish;
    end

endmodule