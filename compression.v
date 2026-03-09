module compression(
    input clk,
    input valid_out, 
    input reset_n,
    input [31:0] W0_in,
    input [31:0] W1_in,
    output [255:0] outsha256, 
    output reg done
);

    // ============================================================
    // 1. KHAI BÁO BIẾN 
    // ============================================================
    reg [31:0] a, b, c, d, e, f, g, h;
    reg [4:0] counter;      
    wire [31:0] K0_in, K1_in; 
    
    // Khởi tạo các biến Hash
    reg [31:0] H0_init, H1_init, H2_init, H3_init, H4_init, H5_init, H6_init, H7_init;
    
    // Module lấy hằng số K
    constant_sha256_unrolled ccc(.counter(counter), .k(K0_in), .k_plus(K1_in));

    // ============================================================
    // 2. CÁC HÀM LOGIC 
    // ============================================================
    function [31:0] Ch(input [31:0] x, y, z);
        Ch = (x & y) ^ (~x & z);
    endfunction

    function [31:0] Maj(input [31:0] x, y, z);
        Maj = (x & y) ^ (x & z) ^ (y & z);
    endfunction

    function [31:0] ROTR(input [31:0] x, input [4:0] n);
        ROTR = (x >> n) | (x << (32 - n));
    endfunction

    function [31:0] Sigma0(input [31:0] x);
        Sigma0 = ROTR(x, 2) ^ ROTR(x, 13) ^ ROTR(x, 22);
    endfunction

    function [31:0] Sigma1(input [31:0] x);
        Sigma1 = ROTR(x, 6) ^ ROTR(x, 11) ^ ROTR(x, 25);
    endfunction

    // ============================================================
    // 3. TỐI ƯU HÓA: ADDER TREE (Cây cộng song song)
    // ============================================================

    // --- ROUND 1 ---
    wire [31:0] s1_e   = Sigma1(e);
    wire [31:0] ch_efg = Ch(e, f, g);
    wire [31:0] kw0    = K0_in + W0_in; // Cộng trước K và W
    
    // T1 = (h + s1) + (ch + kw0)
    wire [31:0] T1 = (h + s1_e) + (ch_efg + kw0);

    wire [31:0] s0_a    = Sigma0(a);
    wire [31:0] maj_abc = Maj(a, b, c);
    wire [31:0] T2      = s0_a + maj_abc;

    // Các biến trung gian sau Round 1
    wire [31:0] e_new = d + T1;     // e của vòng sau
    wire [31:0] a_new = T1 + T2;    // a của vòng sau

    // --- ROUND 2 ---
    wire [31:0] s1_e_n = Sigma1(e_new); 
    wire [31:0] ch_n   = Ch(e_new, e, f);
    wire [31:0] kw1    = K1_in + W1_in; 

    // T10 = (g + s1_n) + (ch_n + kw1)
    wire [31:0] T10 = (g + s1_e_n) + (ch_n + kw1);

    wire [31:0] s0_a_n  = Sigma0(a_new);
    wire [31:0] maj_n   = Maj(a_new, a, b); 
    wire [31:0] T20     = s0_a_n + maj_n;

    // --- KẾT QUẢ CHO NEXT STATE ---
    wire [31:0] next_a = T10 + T20;
    wire [31:0] next_e = c + T10; 

    // ============================================================
    // 4. FSM 
    // ============================================================
    
    assign outsha256 = {H0_init,H1_init,H2_init,H3_init,H4_init,H5_init,H6_init,H7_init};

    localparam IV0 = 32'h6a09e667, IV1 = 32'hbb67ae85, IV2 = 32'h3c6ef372, IV3 = 32'ha54ff53a;
    localparam IV4 = 32'h510e527f, IV5 = 32'h9b05688c, IV6 = 32'h1f83d9ab, IV7 = 32'h5be0cd19;
    localparam IDLE = 2'b00, T1_PROCESS = 2'b10, OUTPUT = 2'b11;

    reg [1:0] state, next_state;

    // 
    always @(*) begin 
        next_state = state;
        case(state)
            IDLE : begin 
                if(valid_out) next_state = T1_PROCESS;
                else          next_state = IDLE;
            end 
            T1_PROCESS : begin 
                if(counter == 31) next_state = OUTPUT;
                else              next_state = T1_PROCESS;
            end
            OUTPUT : begin 
                next_state = IDLE;
            end                                     
            default: next_state = IDLE;
        endcase 
    end

  
    always @(posedge clk or negedge reset_n) begin 
        if(!reset_n) state <= IDLE;
        else       state <= next_state;
    end

    
    always @(posedge clk or negedge reset_n) begin 
        if(!reset_n) begin
            {a, b, c, d, e, f, g, h} <= 256'b0;
            done <= 0;
            H0_init <= IV0; H1_init <= IV1; H2_init <= IV2; H3_init <= IV3;
            H4_init <= IV4; H5_init <= IV5; H6_init <= IV6; H7_init <= IV7;
            counter <= 0;
        end else case(state)
            IDLE: begin 
                done <= 0;
                counter <= 0;
                if(valid_out) begin
                    a<=H0_init; b<=H1_init; c<=H2_init; d<=H3_init;
                    e<=H4_init; f<=H5_init; g<=H6_init; h<=H7_init;
                end
            end             
            T1_PROCESS: begin               
                h <= f;       
                g <= e;       
                f <= e_new;   
                e <= next_e;  
                d <= b;       
                c <= a;       
                b <= a_new;   
                a <= next_a;  
                counter <= counter + 1;
            end            
            OUTPUT: begin
                done <= 1;
                H0_init <= a + H0_init; 
                H1_init <= b + H1_init; 
                H2_init <= c + H2_init;
                H3_init <= d + H3_init;
                H4_init <= e + H4_init; 
                H5_init <= f + H5_init; 
                H6_init <= g + H6_init;
                H7_init <= h + H7_init;
            end
        endcase 
    end
endmodule