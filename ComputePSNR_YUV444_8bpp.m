function [PSNR_Y, PSNR_U, PSNR_V, PSNR_YUV, PSNR_Y_mean, PSNR_U_mean, PSNR_V_mean, PSNR_YUV_mean] = ComputePSNR_YUV444_8bpp(I, R)
% removing weighting channel if needed
I = I(:,:,:,:,1:3);
R = R(:,:,:,:,1:3);
m = size(I,1);
n = size(I,2);
MAX = 255 * 255; % MAX^2 for 10bit

for k = 1:m
    for l = 1:n
        Iyuv = double(squeeze(I(k,l,:,:,:)));
        Ryuv = double(squeeze(R(k,l,:,:,:)));

        ds = (Iyuv(:,:,1) - Ryuv(:,:,1)).^2;
        MSE_Y(k,l) = mean(ds(:));
        PSNR_Y(k,l) = 10*log10(MAX/MSE_Y(k,l));
        
        ds = (Iyuv(:,:,2) - Ryuv(:,:,2)).^2;
        MSE_U(k,l) = mean(ds(:));
        PSNR_U(k,l) = 10*log10(MAX/MSE_U(k,l));
        
        ds = (Iyuv(:,:,3) - Ryuv(:,:,3)).^2;
        MSE_V(k,l) = mean(ds(:));
        PSNR_V(k,l) = 10*log10(MAX/MSE_V(k,l));
        
        PSNR_YUV(k,l) = (6*PSNR_Y(k,l)+PSNR_U(k,l)+PSNR_V(k,l))/8;
    end
end

if m == 15
    PSNR_Y = PSNR_Y(2:end-1,2:end-1); % only the 13x13 are considered
    PSNR_U = PSNR_U(2:end-1,2:end-1);
    PSNR_V = PSNR_V(2:end-1,2:end-1);
    PSNR_YUV = PSNR_YUV(2:end-1,2:end-1);
end

PSNR_Y(isinf(PSNR_Y)) = NaN;
PSNR_U(isinf(PSNR_U)) = NaN;
PSNR_V(isinf(PSNR_V)) = NaN;
PSNR_YUV(isinf(PSNR_YUV)) = NaN;

PSNR_Y_mean = nanmean(PSNR_Y(:));
PSNR_U_mean = nanmean(PSNR_U(:));
PSNR_V_mean = nanmean(PSNR_V(:));
PSNR_YUV_mean = nanmean(PSNR_YUV(:));

% save('PSNRs.mat','PSNR_Y', 'PSNR_U', 'PSNR_V', 'PSNR_YUV', 'PSNR_Y_mean', ' PSNR_U_mean', 'PSNR_V_mean','PSNR_YUV_mean')

