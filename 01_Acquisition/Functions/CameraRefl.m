%% Define Camera
vid = videoinput('gentl', 1, 'Mono12');
src = getselectedsource(vid);
vid.FramesPerTrigger = 1;
src.AcquisitionFrameRate = 3;
src.ExposureTime = 15962;
triggerconfig(vid, 'manual');
triggerconfig(vid, 'hardware', 'DeviceSpecific', 'DeviceSpecific');
triggerconfig(vid, 'immediate');

%Singel preview
preview(vid);
stoppreview(vid);


%Single frames Acq
vid.TriggerRepeat = 0;
start(vid);
stop(vid);

%Multiple frames Acq
vid.TriggerRepeat = Inf;
start(vid);
stoppreview(vid);
stop(vid);

