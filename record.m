clear x y1 y2 obj1 readout;

visadevlist
obj1 = visadev("USB0::0x2A8D::0x2F01::MY54412848::0::INSTR")

% write(obj1, ':FUNCtion:IMPedance:TYPE RX');%%CPD|CPQ|CPG|CPRP|CSD|CSQ|CSRS|LPD|LPQ|LPG|LPRP|LPRD|LSD|LSQ|LSRS|LS
write(obj1, ':FUNCtion:IMPedance:TYPE CPRP');%%CPD|CPQ|CPG|CPRP|CSD|CSQ|CSRS|LPD|LPQ|LPG|LPRP|LPRD|LSD|LSQ|LSRS|LS
%%RD|RX|ZTD|ZTR|GB|YTD|YTR|VDID
write(obj1, ':FREQuency:CW 10000');
write(obj1, ':VOLTage:LEVel 1');
write(obj1, ':APERture SHORt');%SHORt MEDium
write(obj1, ':DISPlay:ENABle 1');%disable display

y_u_wide= []
for x = 0:1:50
pause(0.02)
write(obj1, ':FREQuency:CW ' + string(10000))
readout = writeread(obj1, "FETCh:IMPedance:CORRected?");
readout = writeread(obj1, ":FETCh:IMPedance:FORMatted?");
readout = split(readout,",");
y1 = eval(readout(1));
y2 = eval(readout(2));
y_u_wide = [y_u_wide;[y1,y2]];
end
plot(y_u_wide)