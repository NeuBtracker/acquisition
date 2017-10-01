from time import sleep 
import serial
import crc_ccitt
import crc_16
import numpy as np
import sys
import binascii

#------------------------------------------------------------------------------------------------------------------
def appendCRC16(s):
    crc = crc_16.CRC16()
    crcValue = crc.calculateCRC(s)
    arr=bytearray(s)
    arr.extend([crcValue%256])
    arr.extend([int(crcValue/256)])
    return arr
    
def calculateCRC(s,bitSize):
    crc = crc_ccitt.CRCCCITT(bitSize)
    crc.init_crc_ccitt()
    return(crc.calculateCRC(bytearray(s)))

def set_cur(ser,current,max_cur):    
    current_conv =  (int) (current / max_cur * 4095)  
    highByte = np.uint8(np.int16(current_conv) >>8)
    lowByte = np.uint8(np.int16(current_conv) & 0xFF)
    ser.write(appendCRC16(bytearray([65,119,highByte,lowByte])))
    return binascii.hexlify((appendCRC16(bytearray([65,119,highByte,lowByte]))))



	
    
#------------------------------------------------------------------------------------------------------------------

def connect(com_port):
    ser = serial.Serial(com_port,9600,timeout = 0.5)
    ser.flushInput()
   # ser.write(b"Start")
   # readline = ser.read(7)
   #  print(readline)
   #  if b"Ready" in readline:
   #      print("Lens Driver Ready")
   #   ##  ser.write(appendCRC16(b"MwDA"))
   #   ##  readline = ser.read(7)
   #   ##  print(readline)
   #   ##  print("DC Mode Successful")        
   # else:
   #     print("Error with Lens Driver")
    return ser
#------------------------------------------------------------------------------------------------------------------

com_port ='COM32'
ser = connect(com_port)
max_current = 293

f= open('D:/ZT_Matlab/IndivParts/ETL_pythonP/test.txt','r');
c= f.read()
current = int (c)
print(current)
#current = (int) (sys.argv[1])
s = set_cur(ser,current,max_current)
print(s)

sleep(0.5)
ser.close()

