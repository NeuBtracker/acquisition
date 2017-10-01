import crc_ccitt
import crc_16
import numpy as np
import sys

s=bytearray(sys.argv[1],'hex');
s=s.decode("hex")
print('InputString')
print(s)
crc = crc_16.CRC16()
crcValue = crc.calculateCRC(s)
print('CRC is:')
print(crcValue)
arr=bytearray(s)
arr.extend([crcValue%256])
arr.extend([int(crcValue/256)])
print('The command to sent is')
print(arr)