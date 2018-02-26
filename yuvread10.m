function [Y,U,V]=yuvread10(filename,st,n,R,C,fmt)

% fmt == 3 -> YUV 444
% fmt == 1 -> YUV 420
% fmt == 0 -> YUV 400

fid = fopen(filename,'r');
fseek(fid,0,'eof');
if fmt==3
    if isempty(n)
        n = ftell(fid)/(3*R*C);                   % frame numbers of the file
    end

    for i = st-1 : st+n-2
        fseek(fid,i*R*C*3,'bof');                 % positioning for every frame
                                                    % read 3 channels data from file                                               
        Y(:,:,i+2-st) = ((fread(fid,[C,R],'uint16'))');
        U(:,:,i+2-st) = ((fread(fid,[C,R],'uint16'))');
        V(:,:,i+2-st) = ((fread(fid,[C,R],'uint16'))');  
    end
end
if fmt==1
    if isempty(n)
        n = ftell(fid)/(1.5*R*C);                   % frame numbers of the file
    end

    for i = st-1 : st+n-2
        fseek(fid,i*R*C*1.5,'bof');                 % positioning for every frame
                                                    % read 3 channels data from file                                               
        Y(:,:,i+2-st) = double((fread(fid,[C,R],'uint16'))');
        U(:,:,i+2-st) = double((fread(fid,[C/2,R/2],'uint16'))');
        V(:,:,i+2-st) = double((fread(fid,[C/2,R/2],'uint16'))');  
    end
end
if fmt==0
    if isempty(n)
        n = ftell(fid)/(R*C);                   % frame numbers of the file
    end

    for i = st-1 : st+n-2
        fseek(fid,i*R*C,'bof');                 % positioning for every frame                                                              
        Y(:,:,i+2-st) = double((fread(fid,[C,R],'uint16'))');
    end
end

fclose(fid);