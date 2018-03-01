

residue = double(ref_4DLF_VIEWS) - double(rec_4DLF_VIEWS);

siz = size(rec_4DLF_VIEWS);
height = 13 * siz(3);
width = 13 * siz(4);
rgb_img = uint16(zeros(height, width, 3));
for j = 1:siz(3)
    for i = 1:siz(4)
        ji = 1 + (j - 1) * 13;
        jz = j * 13;
        
        ii = 1 + (i - 1) * 13;
        iz = i * 13;
        
        rec_4DLF_MI(ji:jz, ii:iz, :) = uint16(squeeze(rec_4DLF_VIEWS(1:13, 1:13, j, i, 1:3)));
    end
end

residue_MIs = double(ref_4DLF_MI(1:5642,1:8125)) - double(rec_4DLF_MI);
residue_MIs(residue_MIs<-127)=-127; % clip 
residue_MIs(residue_MIs>128)=128;
residue_MIs = residue_MIs+127; % shift
residue_MIs = uint8(residue_MIs);

figure, imshow(residue_MIs(:,:,1),[0 255])

fileID = fopen( 'residue_I01_HEVC_SS_MI_QP27.yuv', 'w' );
fwrite(fileID, residue_MIs(:,:,1)', 'uint8');
fclose(fileID);

mae_residue = zeros(13,13);
mean_residue = zeros(13,13);
std_residue = zeros(13,13);

cc_spiral = spiral(13);

fileID = fopen( 'residue_animation_I04_HEVC_SS_MI_QP27.yuv', 'w' );

for v = 1:(13 * 13)
        [j, i] = find(cc_spiral == v);

imshow(squeeze(residue(j,i,:,:,1)),[-127 128]);
A = squeeze(residue(j,i,:,:,1));
A(A<-127)=-127; % clip 
A(A>128)=128;
A = A+127; % shift
A = uint8(A);
fwrite(fileID, A', 'uint8');

mae_residue(j,i) = mean(reshape(squeeze(abs(residue(j,i,:,:,1))),[1,434*625]));
mean_residue(j,i) = mean(reshape(squeeze(residue(j,i,:,:,1)),[1,434*625]));
std_residue(j,i) = std(reshape(squeeze(residue(j,i,:,:,1)),[1,434*625]));
%pause(0.3)
    
end

fclose(fileID);

figure, surf(PSNR_YUV)
figure, surf(mean_residue)
figure, surf(std_residue)
figure, surf(mae_residue)

