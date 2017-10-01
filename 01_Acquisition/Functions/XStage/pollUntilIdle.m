function pollUntilIdle(ser, deviceAddress, axisNumber, pauseDuration)
% POLLUNTILIDLE  Poll an axis until it becomes idle.
%   POLLUNTILIDLE(SER, DEVICEADDRESS, AXISNUMBER)
%   POLLUNTILIDLE(SER, DEVICEADDRESS, AXISNUMBER, PAUSEDURATION)
%
% This function sends an empty ASCII command and checks whether an axis has
% become idle. If axis is busy, pauses for a specific duration and retry.
% This function returns when the axis is idle.
%
% PAUSEDURATION is specified in seconds. If not provided, 0.05 is used.
%
% EXAMPLE
% This example sends a 'home' command and waits until axis has finished
% homing.
%   sendCommand(ser, 1, 2, 'home');
%   pollUntilIdle(ser, 1, 2);
%   disp('Finished homing!');
%
% NOTE
% The 'Terminator' property of the serial object should be set to 'CR/LF'
% so that ASCII message footer is properly handled when sending commands
% and receiving replies.
%
% Complete protocol manual can be found at
% http://www.zaber.com/wiki/Manuals/ASCII_Protocol_Manual
 
if nargin < 4
    pauseDuration = 0.05;
end
 
while true
    reply = sendCommand(ser, deviceAddress, axisNumber, '');
    if strcmp(reply.status, 'IDLE') == 1
        % axis is now idle
        break
    end
 
    % axis still busy, sleep a while before checking again
    pause(pauseDuration)
end