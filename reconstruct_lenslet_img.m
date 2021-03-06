function rgb_img = reconstruct_lenslet_img( LF, num_MIs )
    siz = size(LF);
    
    height = num_MIs * siz(3);
    width = num_MIs * siz(4);
    
    rgb_img = uint8(zeros(height, width, siz(5) - 1));
    
    offset = (15 - num_MIs) / 2; % only odd values

for j = 1:siz(3)
    for i = 1:siz(4)
        ji = 1 + (j - 1) * num_MIs;
        jz = j * num_MIs;
        
        ii = 1 + (i - 1) * num_MIs;
        iz = i * num_MIs;
        
        rgb_img(ji:jz, ii:iz, :) = uint8(squeeze(LF(1+offset:15-offset, 1+offset:15-offset, j, i, 1:3)));
    end
end