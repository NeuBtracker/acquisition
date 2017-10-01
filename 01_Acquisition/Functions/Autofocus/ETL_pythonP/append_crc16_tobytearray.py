import crc_ccitt
import crc_16
import numpy as np
import sys
import binascii

s=bytearray(sys.argv[1],'windows-1252');
#print('InputString')
#print(bytes(s))
#print(s)

#print('RemainingString')
#print(bytes(s2))
#print(s2)

crc = crc_16.CRC16()
crcValue = crc.calculateCRC(s)
#print('CRC is:')
#print(crcValue)
arr=bytearray(s)
arr.extend([crcValue%256])
arr.extend([int(crcValue/256)])
#print('The command to sent is')
print(binascii.hexlify (arr))


