module constant_sha256_unrolled (
    input [4:0] counter,     // Bộ đếm 0-31 
    output reg [31:0] k,       // Hằng số cho vòng chẵn 
    output reg [31:0] k_plus // Hằng số cho vòng lẻ
);
    // Đây là logic tổ hợp
    always @(*) begin
        // Gán giá trị 64-bit {k, k_plus}
        case (counter)
            0: {k, k_plus} = {32'h428a2f98, 32'h71374491}; // K[0], K[1]
            1: {k, k_plus} = {32'hb5c0fbcf, 32'he9b5dba5}; // K[2], K[3]
            2: {k, k_plus} = {32'h3956c25b, 32'h59f111f1}; // K[4], K[5]
            3: {k, k_plus} = {32'h923f82a4, 32'hab1c5ed5}; // K[6], K[7]
            4: {k, k_plus} = {32'hd807aa98, 32'h12835b01}; // K[8], K[9]
            5: {k, k_plus} = {32'h243185be, 32'h550c7dc3}; // K[10], K[11]
            6: {k, k_plus} = {32'h72be5d74, 32'h80deb1fe}; // K[12], K[13]
            7: {k, k_plus} = {32'h9bdc06a7, 32'hc19bf174}; // K[14], K[15]
            8: {k, k_plus} = {32'he49b69c1, 32'hefbe4786}; // K[16], K[17]
            9: {k, k_plus} = {32'h0fc19dc6, 32'h240ca1cc}; // K[18], K[19]
            10: {k, k_plus} = {32'h2de92c6f, 32'h4a7484aa}; // K[20], K[21]
            11: {k, k_plus} = {32'h5cb0a9dc, 32'h76f988da}; // K[22], K[23]
            12: {k, k_plus} = {32'h983e5152, 32'ha831c66d}; // K[24], K[25]
            13: {k, k_plus} = {32'hb00327c8, 32'hbf597fc7}; // K[26], K[27]
            14: {k, k_plus} = {32'hc6e00bf3, 32'hd5a79147}; // K[28], K[29]
            15: {k, k_plus} = {32'h06ca6351, 32'h14292967}; // K[30], K[31]
            16: {k, k_plus} = {32'h27b70a85, 32'h2e1b2138}; // K[32], K[33]
            17: {k, k_plus} = {32'h4d2c6dfc, 32'h53380d13}; // K[34], K[35]
            18: {k, k_plus} = {32'h650a7354, 32'h766a0abb}; // K[36], K[37]
            19: {k, k_plus} = {32'h81c2c92e, 32'h92722c85}; // K[38], K[39]
            20: {k, k_plus} = {32'ha2bfe8a1, 32'ha81a664b}; // K[40], K[41]
            21: {k, k_plus} = {32'hc24b8b70, 32'hc76c51a3}; // K[42], K[43]
            22: {k, k_plus} = {32'hd192e819, 32'hd6990624}; // K[44], K[45]
            23: {k, k_plus} = {32'hf40e3585, 32'h106aa070}; // K[46], K[47]
            24: {k, k_plus} = {32'h19a4c116, 32'h1e376c08}; // K[48], K[49]
            25: {k, k_plus} = {32'h2748774c, 32'h34b0bcb5}; // K[50], K[51]
            26: {k, k_plus} = {32'h391c0cb3, 32'h4ed8aa4a}; // K[52], K[53]
            27: {k, k_plus} = {32'h5b9cca4f, 32'h682e6ff3}; // K[54], K[55]
            28: {k, k_plus} = {32'h748f82ee, 32'h78a5636f}; // K[56], K[57]
            29: {k, k_plus} = {32'h84c87814, 32'h8cc70208}; // K[58], K[59]
            30: {k, k_plus} = {32'h90befffa, 32'ha4506ceb}; // K[60], K[61]
            31: {k, k_plus} = {32'hbef9a3f7, 32'hc67178f2}; // K[62], K[63]
            default: {k, k_plus} = 64'b0; // Trường hợp mặc định
        endcase
    end
    

endmodule
