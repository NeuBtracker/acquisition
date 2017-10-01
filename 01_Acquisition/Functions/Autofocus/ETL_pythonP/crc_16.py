class CRC16:
    crc_ccitt_tab = []

    def __init__(self):
        
        self.bitSize=16
        
        if self.bitSize == 16:
            self.crc_constant = 0xA001
            self.starting_value = 0x0000
            
    def updateCRC(self,crc,a):
        if self.bitSize == 16:
            crc=crc^a
            for i in range(0,8):
                if ((crc&1)>0):
                    crc=(crc >> 1) ^ self.crc_constant
                else:
                    crc=(crc >> 1)
            return crc    

    def calculateCRC(self, s):
        
        if self.bitSize == 16:
            crcValue = self.starting_value
            
            for c in s:
                crcValue = self.updateCRC(crcValue,c)
            
            return crcValue
               



