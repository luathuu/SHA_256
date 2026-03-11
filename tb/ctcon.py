import struct
import hashlib

def process_file_for_verilog(input_file, output_file):
    # --- BƯỚC 1: Đọc file input.txt ---
    try:
        with open(input_file, 'r', encoding='utf-8') as f:
            content = f.read()
            # Giữ nguyên .strip() để tránh lỗi ký tự xuống dòng không mong muốn
            content = content.strip() 
    except FileNotFoundError:
        print(f"Lỗi: Không tìm thấy file '{input_file}'")
        return

    # Tính toán kết quả SHA-256 chuẩn để làm Reference (Dòng 2)
    hash_ref = hashlib.sha256(content.encode('utf-8')).hexdigest()
    
    # --- BƯỚC 2: Padding thủ công theo chuẩn SHA-256 (cho Verilog đọc) ---
    message = bytearray(content, 'utf-8')
    orig_len_bits = len(message) * 8
    
    # 2.1 Thêm bit '1' (byte 0x80)
    message.append(0x80)
    
    # 2.2 Thêm bit '0' cho đến khi (len % 64) == 56
    while len(message) % 64 != 56:
        message.append(0x00)
        
    # 2.3 Thêm 64-bit độ dài gốc (Big Endian)
    message += struct.pack('>Q', orig_len_bits)
    
    total_blocks = len(message) // 64

    # --- BƯỚC 3: Ghi file theo cấu trúc mới ---
    with open(output_file, 'w') as f:
        # Dòng 1: Số lượng block (Hex 8 ký tự)
        f.write(f"{total_blocks:08x}\n")
        
        # Dòng 2: Kết quả băm mong đợi (64 ký tự hex)
        f.write(f"{hash_ref}\n")
        
        # Các dòng tiếp theo: Mỗi dòng là 1 block 512-bit (128 ký tự hex)
        for i in range(total_blocks):
            block = message[i*64 : (i+1)*64]
            f.write(block.hex() + "\n")

    print(f"--- THÔNG TIN ---")
    print(f"Nội dung: {content}")
    print(f"Số block: {total_blocks}")
    print(f"Hash mong đợi: {hash_ref}")
    print(f"Đã xuất file '{output_file}' thành công!")

# Chạy hàm
process_file_for_verilog("input.txt", "vectors.hex")