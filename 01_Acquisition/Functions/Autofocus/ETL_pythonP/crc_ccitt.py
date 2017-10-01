from ctypes import c_ushort, c_uint8

class CRCCCITT:
    crc_ccitt_tab = []

    def __init__(self, bitSize):
        
        self.bitSize = bitSize
        
        if bitSize == 16:
            self.crc_ccitt_constant = 0x1021
            self.starting_value = 0xFFFF
            self.init_crc_ccitt()
        elif bitSize == 8:
            self.crc_ccitt_constant = 0x07
            self.starting_value = 0xFF  
            self.init_crc_ccitt()

    def calculateCRC(self, s):
        
        if self.bitSize == 16:
            crcValue = self.starting_value
            self.init_crc_ccitt()
            for c in s:
                tmp = (c_ushort(crcValue >> 8).value) ^ c
                crcValue = (c_ushort(crcValue << 8).value) ^ int(self.crc_ccitt_tab[tmp], 0)
            self.crc_ccitt_tab.clear()
            return crcValue
            
        else:
            crcValue = self.starting_value
            self.init_crc_ccitt()
            for ch in s:
                crcValue = self.crc_ccitt_tab[crcValue^ch]
            self.crc_ccitt_tab.clear()
            return crcValue

    def init_crc_ccitt(self):
        
        if self.bitSize == 16:
            for i in range(0, 256):
                crc = 0
                c = i << 8
    
                for j in range(0, 8):
                    if ((crc ^ c) & 0x8000):  crc = c_ushort(crc << 1).value ^ self.crc_ccitt_constant
                    else: crc = c_ushort(crc << 1).value
    
                    c = c_ushort(c << 1).value 
                self.crc_ccitt_tab.append(hex(crc))
                
        elif self.bitSize == 8:
            for i in range(256):
                
                curr = c_uint8(i).value
                for j in range(8):
                    if (curr & 0x80) != 0:
                        curr = (curr << 1)^ c_uint8(0x07).value
                    else:
                        curr <<= 1
                self.crc_ccitt_tab.append(c_uint8(curr).value)




