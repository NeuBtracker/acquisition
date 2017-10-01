% Specifying serial port examples
% Windows: 'COM5'
% Linux: '/dev/ttyUSB0'
% Mac: '/dev/tty.usbserial-DA00FT01'
portName = 'COM29';
 
deviceAddress = 1;
axisNumber = 1;
 
% Set up serial object
s = serial(portName);
set(s, 'BaudRate',115200, 'DataBits',8, 'FlowControl','none',...
    'Parity','none', 'StopBits',1, 'Terminator','CR/LF');
 
% Open serial port. Fails if port is already opened or non-existent.
fopen(s);
 
try
    % Send a home command, ignoring the reply
    sendCommand(s, deviceAddress, axisNumber, 'home');
 
    % Wait until axis finishes homing
    pollUntilIdle(s, deviceAddress, axisNumber);
 
    % Get current position
    reply = sendCommand(s, deviceAddress, axisNumber, 'get pos');
    pos = str2num(reply.data);
    disp(['Current position is ' num2str(pos) '.']);
 
catch e
    % close port first if an exception occurs
    fclose(s);
    rethrow(e)
end
 
% Close port and clean up serial object
fclose(s);
delete(s);
clear s