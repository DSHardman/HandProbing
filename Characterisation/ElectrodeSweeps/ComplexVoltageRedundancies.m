 
rmss = pressrobot.rms10k();
rmss = rmss(5,[1 7 13 19 25 26]);

phases = pressrobot.phase10k();
phases = phases(5,[1 7 13 19 25 26]);

relrms = zeros([7,1]);
relphases = zeros([7,1]);

relrms(2) = rmss(1);
relphases(2) = phases(1);
[currms, curphase] = wavedifference(rms(2), phases(2), rms(1), phases(1));
relrms(3) = currms;
relphases(3) = curphase;

for i = 3:6
    [currms, curphase] = wavedifference(rms(i), phases(i), currms, curphase);
    relrms(i+1) = currms;
    relphases(i+1) = curphase;
end

% Difference between two sine waves
function [outrms, outphase] = wavedifference(inrms1, inphase1, inrms2, inphase2)
    outrms = sqrt((inrms1*cos(inphase1)-inrms2*cos(inphase2))^2 + ...
        (inrms1*sin(inphase1)-inrms2*sin(inphase2))^2);

    outphase = atan((inrms1*sin(inphase1)-inrms2*sin(inphase2))/...
        (inrms1*cos(inphase1)-inrms2*cos(inphase2)));
end