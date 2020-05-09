cmd = 'C:\Users\PC\Desktop\Âö³åÔëÉù\NoiseMitigation\NoiseMitigation.exe probe_68 0 1 0 0 0 1.5 2';
system(cmd);
fid = fopen('probe_68_rate.txt');
for i=1:2
    line=fgetl(fid);
end
fclose(fid);
results = strsplit(line,',');
for i=1:length(results)
    [token,rem] = strtok(results{i},'=');
    results{i} = rem(3:end);
end