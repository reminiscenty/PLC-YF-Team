function [corr] = Segment(seq1,seq2)
%Segment: calculate the correlation between the sequence 1 and 2; 
%   
    global segnum;
    len = mod(segnum - mod(length(seq1),segnum),segnum);
    % zero padding
    seq1 = [seq1;zeros(len,1)];
    seq2 = [seq2;zeros(len,1)];
    % reshape
    temp = reshape(seq1,[],segnum) .* reshape(seq2,[],segnum);
    % calculate correlation
    corr = sum(abs(sum(temp)));
end

