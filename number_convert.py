def dec_bin(input_dec):
    return bin(input_dec)

def dec_hex(input_dec):
    return hex(input_dec)

def bin_dec(input_bin):
    return int(input_bin)

def bin_hex(input_bin):
    return hex(input_bin)

def hex_dec(input_hex):
    return int(input_hex)

def hex_bin(input_hex):
    return bin(input_hex).zfill(8)

if __name__ == "__main__":
    input_dec = 10
    print(dec_bin(input_dec))
    print(dec_hex(input_dec))

    input_bin = 10000
    input_bin = int(str(input_bin),2)
    print(bin_dec(input_bin))
    print(bin_hex(input_bin))

    input_hex = 0x20
    print(hex_dec(input_hex))
    print(hex_bin(input_hex))