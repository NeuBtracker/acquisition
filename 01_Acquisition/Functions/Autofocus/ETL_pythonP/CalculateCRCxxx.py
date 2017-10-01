import sys
import crc_ccitt
import crc_16
import numpy as np


calculateCRC(sys.argv[1],bitSize):
crc = crc_ccitt.CRCCCITT(bitSize)
crc.init_crc_ccitt()
print(crc.calculateCRC(bytearray(s)))