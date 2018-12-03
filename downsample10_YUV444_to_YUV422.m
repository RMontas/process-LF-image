% script performing 444 to 422 downsampling

% Input: image in YCbCr 444 sampling 10 bits in uint16 representation [0-1023]

% Output: 3x1 cell, each cell item contatin one channel Y,Cb, Cr
% coresponding to 422 solor sampling

function [out] = downsample10_YUV444_to_YUV422(in)

out = cell(3,1);
for i=1:3
    out{i} = in(:,:,i);
end

for i=2:3
    tmp = imfilter(double(out{i}), [1 6 1], 'replicate', 'same');
    out{i} = uint16(tmp(:,1:2:end));
    tmp = imfilter(out{i}, [0 ; 4 ; 4], 'replicate', 'same');
    out{i} = uint16((tmp(:,:) + 32) / 64);
end

%for i=2:3
%    tmp = imfilter(out{i}, [0 ; 4 ; 4], 'replicate', 'same');
%    out{i} = uint16((tmp(1:2:end,:) + 32) / 64);
%end
