% REF : prev gen (lenslet -> 4DLF) - (C&G Correction) 
% REC : codec limitation YUV444@10bpp
% representation_type: lenslet (requires LF toolbox + metadata), 4DLF_MI or 4DLF_PVS
% metadata: is generated when we run gen_4DLF.m (e.g. I01_Bikes__Decoded.mat)

% REF image is converted from RGB444@10bpp to YUV444@10bpp 4DLF_VIEWS
% REC image is expected to be YUV444@10bpp and it is converted to 4DLF_VIEWS to compare with REF

% if REC is lenslet than the following steps are necessary:
% (lenslet -> 4DLF_VIEWS) - (C&G Correction) - (RGB444@10bpp -> YUV444@10bpp)
% if REC is 4DLF_MI than the following steps are necessary:
% (4DLF_MI -> 4DLF_VIEWS)

% REF is assumed to always be 9376x6512x3 (YUV444@10bpp) for 15x15 MI
% REF is assumed to always be 8128x5648x3 (YUV444@10bpp) for 13x13 MI
% REC view size is assumed to always be 625x434x3 

function [] = calcMetrics_YUV444_10bpp(REF, REC, representation_type, H, W, mi_size, metadata, output_folder)

% process REF
if mi_size == 15
    W_REF = 9376;
    H_REF = 6512;
else % 13x13
    W_REF = 8128;
    H_REF = 5648;
end
f = fopen(REF,'r');
Y = fread(f, [W_REF H_REF], 'uint16');
U = fread(f, [W_REF H_REF], 'uint16');
V = fread(f, [W_REF H_REF], 'uint16');
fclose(f);
ref_4DLF_MI = uint16(cat(3, Y', U', V'));
clear Y U V
ref_4DLF_VIEWS = deconstruct_lenslet_img10( ref_4DLF_MI, mi_size ); % 4DLF_MI to 4DLF_VIEWS
timestamp = fix(clock);
timestamp = strcat(num2str(timestamp(4),2),num2str(timestamp(5),2),num2str(timestamp(6),2));
imwrite(ycbcr2rgb(squeeze(ref_4DLF_VIEWS((mi_size+1)/2,(mi_size+1)/2,:,:,1:3))*64), strcat(output_folder, 'REF_central_view_',timestamp,'.png'), 'png');

% process REC
if representation_type == 2 %% 4DLF_PVS
    % convert to YUV444@10bpp and compare
    cc_spiral = spiral(mi_size);
    f = fopen(REC,'r');
    for j = 1:mi_size
        for i = 1:mi_size
            [ypos, xpos] = find(cc_spiral == (j-1)*mi_size + i);
            Y = fread(f, [W H], 'uint16');
            U = fread(f, [W H], 'uint16');
            V = fread(f, [W H], 'uint16');
            Y = Y'; U = U'; V = V';
            rec_4DLF_VIEWS(ypos,xpos,:,:,1) = uint16(Y(1:434,1:625));
            rec_4DLF_VIEWS(ypos,xpos,:,:,2) = uint16(U(1:434,1:625));
            rec_4DLF_VIEWS(ypos,xpos,:,:,3) = uint16(V(1:434,1:625));
        end
    end
    fclose(f);
else
    f = fopen(REC,'r');
    Y = fread(f, [W H], 'uint16');
    U = fread(f, [W H], 'uint16');
    V = fread(f, [W H], 'uint16');
    fclose(f);
    Y = Y'; U = U'; V = V';
    rec_YUV444_10bpp(:,:,1) = Y;
    rec_YUV444_10bpp(:,:,2) = U;
    rec_YUV444_10bpp(:,:,3) = V;
    clear Y U V
    if representation_type == 0 %% LENS
        rec_RGB444_10bpp = single(ycbcr2rgb(double(rec_YUV444_10bpp) / 1023));
        run('LFToolbox0.4/LFMatlabPathSetup')
        [rec_4DLF_VIEWS_RGB444_10bpp, LFdec, LFWeight, DecodeOptions, CorrectedLensletImage] = DecodeLenslet_RGB444_10bpp( rec_RGB444_10bpp, metadata);
        for i = 1:mi_size
            for j = 1:mi_size
                rec_4DLF_VIEWS(j,i,:,:,:) = uint16(rgb2ycbcr(double(squeeze(rec_4DLF_VIEWS_RGB444_10bpp(j,i,:,:,:)))) * 1023);
            end
        end
    elseif representation_type == 1 %% 4DLF_MI
        rec_4DLF_VIEWS = deconstruct_lenslet_img10( uint16(rec_YUV444_10bpp), mi_size ); % 4DLF_MI to 4DLF_VIEWS
    end
end
imwrite(ycbcr2rgb(squeeze(rec_4DLF_VIEWS((mi_size+1)/2,(mi_size+1)/2,:,:,1:3))*64), strcat(output_folder, 'REC_central_view_',timestamp,'.png'), 'png');

[PSNR_Y, PSNR_U, PSNR_V, PSNR_YUV, PSNR_Y_mean, PSNR_U_mean, PSNR_V_mean, PSNR_YUV_mean] = ComputePSNR_YUV444_10bpp(rec_4DLF_VIEWS, ref_4DLF_VIEWS);

fileID = fopen( strcat(output_folder,'avg_psnr_y.txt'), 'a' );
fprintf(fileID, "%f\n",PSNR_Y_mean);
fclose(fileID);
fileID = fopen( strcat(output_folder,'avg_psnr_yuv.txt'), 'a' );
fprintf(fileID, "%f\n",PSNR_YUV_mean);
fclose(fileID);

%PSNR_Y, PSNR_U, PSNR_V, PSNR_YUV, PSNR_Y_mean, PSNR_U_mean, PSNR_V_mean, PSNR_YUV_mean
%disp('PSNR_Y_mean and PSNR_YUV_mean')
%disp(PSNR_Y_mean)
%disp(PSNR_YUV_mean);

%fileID = fopen( 'tmp_ref_4dlf_view_7_7.yuv', 'w' );
%fwrite(fileID, permute(squeeze(ref_4DLF_VIEWS(7,7,:,:,:)), [2 1 3]), 'uint16');
%fclose(fileID);
%fileID = fopen( 'tmp_rec_lens_view_7_7.yuv', 'w' );
%fwrite(fileID, permute(squeeze(rec_4DLF_VIEWS(7,7,:,:,:)), [2 1 3]), 'uint16');
%fclose(fileID);
