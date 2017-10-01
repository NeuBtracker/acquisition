function reply = sendCommand(ser, deviceAddress, axisNumber, command)
% SENDCOMMAND  Send an ASCII command to a Zaber device and receive a reply.
%   REPLY = SENDCOMMAND(SER, DEVICEADDRESS, AXISNUMBER, COMMAND)
%
% This function sends an ASCII command formatted as
% '/DEVICEADDRESS AXISNUMBER COMMAND\n' to the serial object SER.
% The reply is formatted as a struct.
%
% EXAMPLE
% sendCommand(s,1,2,'move abs 256') will result in
%   '/1 2 move abs 256\n'
% being sent to the device at serial object s, and a struct
%            type : '@'
%   deviceAddress : 1
%      axisNumber : 2
%            flag : 'OK'
%          status : 'BUSY'
%         warning : '--'
%            data : '0'
% to be returned by the function.
%
% NOTE
% The 'Terminator' property of the serial object should be set to 'CR/LF'
% so that ASCII message footer is properly handled when sending commands
% and receiving replies.
%
% Complete protocol manual can be found at
% http://www.zaber.com/wiki/Manuals/ASCII_Protocol_Manual
 
if isempty(command)
    fprintf(ser, '/%d %d\n', [deviceAddress, axisNumber]);
else
    fprintf(ser, '/%d %d %s\n', [deviceAddress, axisNumber, command]);
end
 
% Get device reply. FGETL blocks a line is received.
replyStr = fgetl(ser);
 
% Parse reply into struct.
[type, deviceAddress, axisNumber, flag, status, warning, data] = ...
    strread(replyStr, '%c%d %d %s %s %s %s');
reply = struct('type', type, 'deviceAddress', deviceAddress,...
    'axisNumber', axisNumber, 'flag', flag, 'status', status,...
    'warning', warning, 'data', data);