use_10bpp = 0;
use_13x13 = 1;
use_MI = 0;
use_PVS = 1;
use_VI = 0; %% TODO 

if use_13x13 == 1
    num_MIs = 13;
else
    num_MIs = 15;
end

img2use = pwd;

run('LFToolbox0.4/LFMatlabPathSetup')

% Creates the appropriate folders if they don't exist
if (use_MI)
    if (~exist('4DLF_MI', 'dir'))
        mkdir('4DLF_MI');
    end
end
if (use_PVS)
    if (~exist('4DLF_PVS', 'dir'))
        mkdir('4DLF_PVS');
    end
end
if (use_VI)
    if (~exist('4DLF_VI', 'dir'))
        mkdir('4DLF_VI');
    end
end
if (~exist('thumbnails', 'dir'))
    mkdir('thumbnails');
end

% Creates a parallel pool to speed up the process
if isempty(gcp('nocreate'))
    myCluster = parcluster('local');
    myCluster.NumWorkers = 8;
    parpool(myCluster, 8)
end

% Setup the appropriate path for the LF toolbox
LFMatlabPathSetup

% Builds white image database
LFUtilProcessWhiteImages;

% Check the files to convert on current folder
listing = dir('*.LFR');
nfiles = size(listing);
nfiles = nfiles(1);

%parfor i = 1:nfiles
for i = 1:1
    % Decodes de Light Field (LFR)
    LFUtilDecodeLytroFolder(strcat('./', listing(i).name), [], struct('OptionalTasks', 'ColourCorrect2')); 
    %LFUtilDecodeLytroFolder(strcat('./', listing(i).name)); 
end

% Check the files to convert on current folder
listing = dir('*.mat');

nfiles = size(listing);
nfiles = nfiles(1);

% Creates the appropriate folders if they don't exist
if (use_MI)
    if (~exist('4DLF_MI', 'dir'))
        mkdir('4DLF_MI');
    end
end
if (use_PVS)
    if (~exist('4DLF_PVS', 'dir'))
        mkdir('4DLF_PVS');
    end
end
if (use_VI)
    if (~exist('4DLF_VI', 'dir'))
        mkdir('4DLF_VI');
    end
end
if (~exist('thumbnails', 'dir'))
    mkdir('thumbnails');
end

% Cycle through the files to convert
%for i = 1:nfiles
for i = 1:1
    [path, name, ~] = fileparts(listing(i).name);
    if use_13x13 == 1
        name = strcat(name, '_13x13');
    end
    
    % Read LF mat
    LF = load(listing(i).name);
    LF = LF.LF;
    
    % Conversion to 8 or 10 bpp
    if use_10bpp == 1
        LF = uint16(double(LF) ./ 65535 .* 1023);
        lenslet_rgb_img = reconstruct_lenslet_img10(LF, num_MIs);
    else
        LF = uint8(double(LF) ./ 65535 .* 255);
        lenslet_rgb_img = reconstruct_lenslet_img(LF, num_MIs);
    end
    
    %% Lenslet
   % lenslet_rgb_img = reconstruct_lenslet_img(LF);
    
    imwrite(lenslet_rgb_img, strcat(path, 'thumbnails/', name, '.png'), 'png');
    
    [Y, X, Z] = size(lenslet_rgb_img);
    
    % Operations to adapt the resolution
    while (mod(Y, 8) ~= 0)
        lenslet_rgb_img(end + 1, :, :) = lenslet_rgb_img(end, :, :);
        [Y, X, Z] = size(lenslet_rgb_img);
    end
    
    while (mod(X, 8) ~= 0)
        lenslet_rgb_img(:, end + 1, :) = lenslet_rgb_img(:, end, :);
        [Y, X, Z] = size(lenslet_rgb_img);
    end
    
    if (i == 1)
        fprintf('Lenslet rectified resolution: %d %d\n', Y, X);
    end
    
    % RGB 2 YUV conversion
    if use_10bpp == 1
        lenslet_yuv_img = uint16(rgb2ycbcr(double(lenslet_rgb_img) / 1023) * 1023);
    else
        lenslet_yuv_img = rgb2ycbcr(lenslet_rgb_img);
    end
    
    if (use_MI)
        % YUV444 2 YUV420 conversion
        if use_10bpp == 1
            lenslet_yuv420_img = downsample10(lenslet_yuv_img);
            % RGB Actual writing
            fileID = fopen( strcat(path, '4DLF_MI/', name, '_RGB444_10bpp.rgb'), 'w' );
            fwrite(fileID, permute(lenslet_rgb_img, [2 1 3]), 'uint16');
            fclose(fileID);
            fileID = fopen( strcat(path, '4DLF_MI/', name, '_R444_10bpp.rgb'), 'w' );
            fwrite(fileID, lenslet_rgb_img(:, :, 1)', 'uint16');
            fclose(fileID);
            fileID = fopen( strcat(path, '4DLF_MI/', name, '_G444_10bpp.rgb'), 'w' );
            fwrite(fileID, lenslet_rgb_img(:, :, 2)', 'uint16');
            fclose(fileID);
            fileID = fopen( strcat(path, '4DLF_MI/', name, '_B444_10bpp.rgb'), 'w' );
            fwrite(fileID, lenslet_rgb_img(:, :, 3)', 'uint16');
            fclose(fileID);
            % YUV Actual writing
            fileID = fopen( strcat(path, '4DLF_MI/', name, '_YUV444_10bpp.yuv'), 'w' );
            fwrite(fileID, permute(lenslet_yuv_img, [2 1 3]), 'uint16');
            fclose(fileID);
            fileID = fopen( strcat(path, '4DLF_MI/', name, '_Y444_10bpp.yuv'), 'w' );
            fwrite(fileID, lenslet_yuv_img(:, :, 1)', 'uint16');
            fclose(fileID);
            fileID = fopen( strcat(path, '4DLF_MI/', name, '_U444_10bpp.yuv'), 'w' );
            fwrite(fileID, lenslet_yuv_img(:, :, 2)', 'uint16');
            fclose(fileID);
            fileID = fopen( strcat(path, '4DLF_MI/', name, '_V444_10bpp.yuv'), 'w' );
            fwrite(fileID, lenslet_yuv_img(:, :, 3)', 'uint16');
            fclose(fileID);
            % YUV Actual writing
            fileID = fopen( strcat(path, '4DLF_MI/', name, '_YUV420_10bpp.yuv'), 'w' );
            fwrite(fileID, lenslet_yuv420_img{1}', 'uint16');
            fwrite(fileID, lenslet_yuv420_img{2}', 'uint16');
            fwrite(fileID, lenslet_yuv420_img{3}', 'uint16');
            fclose(fileID);
            fileID = fopen( strcat(path, '4DLF_MI/', name, '_Y420_10bpp.yuv'), 'w' );
            fwrite(fileID, lenslet_yuv420_img{1}', 'uint16');
            fclose(fileID);
            fileID = fopen( strcat(path, '4DLF_MI/', name, '_U420_10bpp.yuv'), 'w' );
            fwrite(fileID, lenslet_yuv420_img{2}', 'uint16');
            fclose(fileID);
            fileID = fopen( strcat(path, '4DLF_MI/', name, '_V420_10bpp.yuv'), 'w' );
            fwrite(fileID, lenslet_yuv420_img{3}', 'uint16');
            fclose(fileID);
        else
            lenslet_yuv420_img = downsample(lenslet_yuv_img);
            % RGB Actual writing
            fileID = fopen( strcat(path, '4DLF_MI/', name, '_RGB444_8bpp.rgb'), 'w' );
            fwrite(fileID, permute(lenslet_rgb_img, [2 1 3]), 'uint8');
            fclose(fileID);
            fileID = fopen( strcat(path, '4DLF_MI/', name, '_R444_8bpp.rgb'), 'w' );
            fwrite(fileID, lenslet_rgb_img(:, :, 1)', 'uint8');
            fclose(fileID);
            fileID = fopen( strcat(path, '4DLF_MI/', name, '_G444_8bpp.rgb'), 'w' );
            fwrite(fileID, lenslet_rgb_img(:, :, 2)', 'uint8');
            fclose(fileID);
            fileID = fopen( strcat(path, '4DLF_MI/', name, '_B444_8bpp.rgb'), 'w' );
            fwrite(fileID, lenslet_rgb_img(:, :, 3)', 'uint8');
            fclose(fileID);
            % YUV Actual writing
            fileID = fopen( strcat(path, '4DLF_MI/', name, '_YUV444_8bpp.yuv'), 'w' );
            fwrite(fileID, permute(lenslet_yuv_img, [2 1 3]), 'uint8');
            fclose(fileID);
            fileID = fopen( strcat(path, '4DLF_MI/', name, '_Y444_8bpp.yuv'), 'w' );
            fwrite(fileID, lenslet_yuv_img(:, :, 1)', 'uint8');
            fclose(fileID);
            fileID = fopen( strcat(path, '4DLF_MI/', name, '_U444_8bpp.yuv'), 'w' );
            fwrite(fileID, lenslet_yuv_img(:, :, 2)', 'uint8');
            fclose(fileID);
            fileID = fopen( strcat(path, '4DLF_MI/', name, '_V444_8bpp.yuv'), 'w' );
            fwrite(fileID, lenslet_yuv_img(:, :, 3)', 'uint8');
            fclose(fileID);
            % YUV Actual writing
            fileID = fopen( strcat(path, '4DLF_MI/', name, '_YUV420_8bpp.yuv'), 'w' );
            fwrite(fileID, lenslet_yuv420_img{1}', 'uint8');
            fwrite(fileID, lenslet_yuv420_img{2}', 'uint8');
            fwrite(fileID, lenslet_yuv420_img{3}', 'uint8');
            fclose(fileID);
            fileID = fopen( strcat(path, '4DLF_MI/', name, '_Y420_8bpp.yuv'), 'w' );
            fwrite(fileID, lenslet_yuv420_img{1}', 'uint8');
            fclose(fileID);
            fileID = fopen( strcat(path, '4DLF_MI/', name, '_U420_8bpp.yuv'), 'w' );
            fwrite(fileID, lenslet_yuv420_img{2}', 'uint8');
            fclose(fileID);
            fileID = fopen( strcat(path, '4DLF_MI/', name, '_V420_8bpp.yuv'), 'w' );
            fwrite(fileID, lenslet_yuv420_img{3}', 'uint8');
            fclose(fileID);
        end
    end
    
    %% Views
    [mv_size, ~, Y, X, Z] = size(LF);
    
    cc_spiral = spiral(mv_size); % Depends on the micro-views size
    
    views_rgb_img = [];% zeros(Y, X, Z - 1, mv_size * mv_size);
    views_yuv_img = [];
    views_yuv420_img = [];
    
    for j = 1:(num_MIs * num_MIs)
        [ypos, xpos] = find(cc_spiral == j);
        
        views_rgb_img = cat(4, views_rgb_img, squeeze(LF(ypos, xpos, :, :, 1:3)));
        %views_yuv_img = cat(4, views_yuv_img, rgb2ycbcr(squeeze(LF(ypos, xpos, :, :, 1:3))));
        
        if use_10bpp == 1
          %  lenslet_yuv_img = uint16(rgb2ycbcr(double(lenslet_rgb_img) / 1023) * 1023);
            views_yuv_img = cat(4, views_yuv_img, uint16(rgb2ycbcr(double(squeeze(LF(ypos, xpos, :, :, 1:3)))/1023)*1023));
        else
           % lenslet_yuv_img = rgb2ycbcr(lenslet_rgb_img);
            views_yuv_img = cat(4, views_yuv_img, rgb2ycbcr(squeeze(LF(ypos, xpos, :, :, 1:3))));
        end
        
        
    end
    
    % Operations to adapt the resolution
    [Y, X, C, Z] = size(views_rgb_img);
    
    while (mod(Y, 8) ~= 0)
        views_rgb_img(end + 1, :, :, :) = views_rgb_img(end, :, :, :);
        views_yuv_img(end + 1, :, :, :) = views_yuv_img(end, :, :, :);
        [Y, X, C, Z] = size(views_rgb_img);
    end
    
    while (mod(X, 8) ~= 0)
        views_rgb_img(:, end + 1, :, :) = views_rgb_img(:, end, :, :);
        views_yuv_img(:, end + 1, :, :) = views_yuv_img(:, end, :, :);
        [Y, X, C, Z] = size(views_rgb_img);
    end
    
    if (i == 1)
        fprintf('Views rectified resolution: %d %d\n', Y, X);
    end
    
    if (use_PVS)
        if use_10bpp == 1
            % RGB Actual writing
            fileID = fopen( strcat(path, '4DLF_PVS/', name, '_RGB444_10bpp.rgb'), 'w' );
            fwrite(fileID, permute(views_rgb_img, [2 1 3 4]), 'uint16');
            fclose(fileID);
            fileID = fopen( strcat(path, '4DLF_PVS/', name, '_R444_10bpp.rgb'), 'w' );
            fwrite(fileID, permute(squeeze(views_rgb_img(:, :, 1, :)), [2 1 3]), 'uint16');
            fileID = fopen( strcat(path, '4DLF_PVS/', name, '_G444_10bpp.rgb'), 'w' );
            fwrite(fileID, permute(squeeze(views_rgb_img(:, :, 2, :)), [2 1 3]), 'uint16');
            fclose(fileID);
            fileID = fopen( strcat(path, '4DLF_PVS/', name, '_B444_10bpp.rgb'), 'w' );
            fwrite(fileID, permute(squeeze(views_rgb_img(:, :, 3, :)), [2 1 3]), 'uint16');
            fclose(fileID);
            % YUV Actual writing
            fileID = fopen( strcat(path, '4DLF_PVS/', name, '_YUV444_10bpp.yuv'), 'w' );
            fwrite(fileID, permute(views_yuv_img, [2 1 3 4]), 'uint16');
            fclose(fileID);
            fileID = fopen( strcat(path, '4DLF_PVS/', name, '_Y444_10bpp.yuv'), 'w' );
            fwrite(fileID, permute(squeeze(views_yuv_img(:, :, 1, :)), [2 1 3]), 'uint16');
            fileID = fopen( strcat(path, '4DLF_PVS/', name, '_U444_10bpp.yuv'), 'w' );
            fwrite(fileID, permute(squeeze(views_yuv_img(:, :, 2, :)), [2 1 3]), 'uint16');
            fclose(fileID);
            fileID = fopen( strcat(path, '4DLF_PVS/', name, '_V444_10bpp.yuv'), 'w' );
            fwrite(fileID, permute(squeeze(views_yuv_img(:, :, 3, :)), [2 1 3]), 'uint16');
            fclose(fileID);
            % YUV Actual writing
            fileID = fopen( strcat(path, '4DLF_PVS/', name, '_YUV420_10bpp.yuv'), 'w' );
            for v = 1:num_MIs*num_MIs
                views_yuv420_img = downsample10(views_yuv_img(:,:,:,v));
                fwrite(fileID, views_yuv420_img{1}', 'uint16');
                fwrite(fileID, views_yuv420_img{2}', 'uint16');
                fwrite(fileID, views_yuv420_img{3}', 'uint16');
            end
            fclose(fileID);
            fileID = fopen( strcat(path, '4DLF_PVS/', name, '_Y420_10bpp.yuv'), 'w' );
            for v = 1:num_MIs*num_MIs
                views_yuv420_img = downsample10(views_yuv_img(:,:,:,v));
                fwrite(fileID, views_yuv420_img{1}', 'uint16');
            end
            fclose(fileID);
            fileID = fopen( strcat(path, '4DLF_PVS/', name, '_U420_10bpp.yuv'), 'w' );
            for v = 1:num_MIs*num_MIs
                views_yuv420_img = downsample10(views_yuv_img(:,:,:,v));
                fwrite(fileID, views_yuv420_img{2}', 'uint16');
            end
            fclose(fileID);
            fileID = fopen( strcat(path, '4DLF_PVS/', name, '_V420_10bpp.yuv'), 'w' );
            for v = 1:num_MIs*num_MIs
                views_yuv420_img = downsample10(views_yuv_img(:,:,:,v));
                fwrite(fileID, views_yuv420_img{3}', 'uint16');
            end
            fclose(fileID);
        else
            % RGB Actual writing
            fileID = fopen( strcat(path, '4DLF_PVS/', name, '_RGB444_8bpp.rgb'), 'w' );
            fwrite(fileID, permute(views_rgb_img, [2 1 3 4]), 'uint8');
            fclose(fileID);
            fileID = fopen( strcat(path, '4DLF_PVS/', name, '_R444_8bpp.rgb'), 'w' );
            fwrite(fileID, permute(squeeze(views_rgb_img(:, :, 1, :)), [2 1 3]), 'uint8');
            fileID = fopen( strcat(path, '4DLF_PVS/', name, '_G444_8bpp.rgb'), 'w' );
            fwrite(fileID, permute(squeeze(views_rgb_img(:, :, 2, :)), [2 1 3]), 'uint8');
            fclose(fileID);
            fileID = fopen( strcat(path, '4DLF_PVS/', name, '_B444_8bpp.rgb'), 'w' );
            fwrite(fileID, permute(squeeze(views_rgb_img(:, :, 3, :)), [2 1 3]), 'uint8');
            fclose(fileID);
            % YUV Actual writing
            fileID = fopen( strcat(path, '4DLF_PVS/', name, '_YUV444_8bpp.yuv'), 'w' );
            fwrite(fileID, permute(views_yuv_img, [2 1 3 4]), 'uint8');
            fclose(fileID);
            fileID = fopen( strcat(path, '4DLF_PVS/', name, '_Y444_8bpp.yuv'), 'w' );
            fwrite(fileID, permute(squeeze(views_yuv_img(:, :, 1, :)), [2 1 3]), 'uint8');
            fileID = fopen( strcat(path, '4DLF_PVS/', name, '_U444_8bpp.yuv'), 'w' );
            fwrite(fileID, permute(squeeze(views_yuv_img(:, :, 2, :)), [2 1 3]), 'uint8');
            fclose(fileID);
            fileID = fopen( strcat(path, '4DLF_PVS/', name, '_V444_8bpp.yuv'), 'w' );
            fwrite(fileID, permute(squeeze(views_yuv_img(:, :, 3, :)), [2 1 3]), 'uint8');
            fclose(fileID);
            % YUV Actual writing
            fileID = fopen( strcat(path, '4DLF_PVS/', name, '_YUV420_8bpp.yuv'), 'w' );
            for v = 1:num_MIs*num_MIs
                views_yuv420_img = downsample(views_yuv_img(:,:,:,v));
                fwrite(fileID, views_yuv420_img{1}', 'uint8');
                fwrite(fileID, views_yuv420_img{2}', 'uint8');
                fwrite(fileID, views_yuv420_img{3}', 'uint8');
            end
            fclose(fileID);
            fileID = fopen( strcat(path, '4DLF_PVS/', name, '_Y420_8bpp.yuv'), 'w' );
            for v = 1:num_MIs*num_MIs
                views_yuv420_img = downsample(views_yuv_img(:,:,:,v));
                fwrite(fileID, views_yuv420_img{1}', 'uint8');
            end
            fclose(fileID);
            fileID = fopen( strcat(path, '4DLF_PVS/', name, '_U420_8bpp.yuv'), 'w' );
            for v = 1:num_MIs*num_MIs
                views_yuv420_img = downsample(views_yuv_img(:,:,:,v));
                fwrite(fileID, views_yuv420_img{2}', 'uint8');
            end
            fclose(fileID);
            fileID = fopen( strcat(path, '4DLF_PVS/', name, '_V420_8bpp.yuv'), 'w' );
            for v = 1:num_MIs*num_MIs
                views_yuv420_img = downsample(views_yuv_img(:,:,:,v));
                fwrite(fileID, views_yuv420_img{3}', 'uint8');
            end
            fclose(fileID);
        end
    end
    
    %% Views Image - All the views concatenated in one single frame
    
     % Conversion to 8 or 10 bpp
    if use_10bpp == 1
        views_rgb_imgVI = deconstruct_lenslet_imgVI10(LF, num_MIs);
    else
        views_rgb_imgVI = deconstruct_lenslet_imgVI(LF, num_MIs);
    end
    
    [Y, X, Z] = size(views_rgb_imgVI);
    
    % Operations to adapt the resolution
    while (mod(Y, 8) ~= 0)
        views_rgb_imgVI(end + 1, :, :) = views_rgb_imgVI(end, :, :);
        [Y, X, Z] = size(views_rgb_imgVI);
    end
    
    while (mod(X, 8) ~= 0)
        views_rgb_imgVI(:, end + 1, :) = views_rgb_imgVI(:, end, :);
        [Y, X, Z] = size(views_rgb_imgVI);
    end
    
    if (i == 1)
        fprintf('Lenslet rectified resolution: %d %d\n', Y, X);
    end
    
    % RGB 2 YUV conversion
    if use_10bpp == 1
        views_yuv_imgVI = uint16(rgb2ycbcr(double(views_rgb_imgVI) / 1023) * 1023);
    else
        views_yuv_imgVI = rgb2ycbcr(views_rgb_imgVI);
    end
    
    if (use_VI)
        % YUV444 2 YUV420 conversion
        if use_10bpp == 1
            views_yuv420_imgVI = downsample10(views_yuv_imgVI);
            % RGB Actual writing
            fileID = fopen( strcat(path, '4DLF_VI/', name, '_RGB444_10bpp.rgb'), 'w' );
            fwrite(fileID, permute(views_rgb_imgVI, [2 1 3]), 'uint16');
            fclose(fileID);
            fileID = fopen( strcat(path, '4DLF_VI/', name, '_R444_10bpp.rgb'), 'w' );
            fwrite(fileID, views_rgb_imgVI(:, :, 1)', 'uint16');
            fclose(fileID);
            fileID = fopen( strcat(path, '4DLF_VI/', name, '_G444_10bpp.rgb'), 'w' );
            fwrite(fileID, views_rgb_imgVI(:, :, 2)', 'uint16');
            fclose(fileID);
            fileID = fopen( strcat(path, '4DLF_VI/', name, '_B444_10bpp.rgb'), 'w' );
            fwrite(fileID, views_rgb_imgVI(:, :, 3)', 'uint16');
            fclose(fileID);
            % YUV Actual writing
            fileID = fopen( strcat(path, '4DLF_VI/', name, '_YUV444_10bpp.yuv'), 'w' );
            fwrite(fileID, permute(views_yuv_imgVI, [2 1 3]), 'uint16');
            fclose(fileID);
            fileID = fopen( strcat(path, '4DLF_VI/', name, '_Y444_10bpp.yuv'), 'w' );
            fwrite(fileID, views_yuv_imgVI(:, :, 1)', 'uint16');
            fclose(fileID);
            fileID = fopen( strcat(path, '4DLF_VI/', name, '_U444_10bpp.yuv'), 'w' );
            fwrite(fileID, views_yuv_imgVI(:, :, 2)', 'uint16');
            fclose(fileID);
            fileID = fopen( strcat(path, '4DLF_VI/', name, '_V444_10bpp.yuv'), 'w' );
            fwrite(fileID, views_yuv_imgVI(:, :, 3)', 'uint16');
            fclose(fileID);
            % YUV Actual writing
            fileID = fopen( strcat(path, '4DLF_VI/', name, '_YUV420_10bpp.yuv'), 'w' );
            fwrite(fileID, views_yuv420_imgVI{1}', 'uint16');
            fwrite(fileID, views_yuv420_imgVI{2}', 'uint16');
            fwrite(fileID, views_yuv420_imgVI{3}', 'uint16');
            fclose(fileID);
            fileID = fopen( strcat(path, '4DLF_VI/', name, '_Y420_10bpp.yuv'), 'w' );
            fwrite(fileID, views_yuv420_imgVI{1}', 'uint16');
            fclose(fileID);
            fileID = fopen( strcat(path, '4DLF_VI/', name, '_U420_10bpp.yuv'), 'w' );
            fwrite(fileID, views_yuv420_imgVI{2}', 'uint16');
            fclose(fileID);
            fileID = fopen( strcat(path, '4DLF_VI/', name, '_V420_10bpp.yuv'), 'w' );
            fwrite(fileID, views_yuv420_imgVI{3}', 'uint16');
            fclose(fileID);
        else
            views_yuv420_imgVI = downsample(views_yuv_imgVI);
            % RGB Actual writing
            fileID = fopen( strcat(path, '4DLF_VI/', name, '_RGB444_8bpp.rgb'), 'w' );
            fwrite(fileID, permute(views_rgb_imgVI, [2 1 3]), 'uint8');
            fclose(fileID);
            fileID = fopen( strcat(path, '4DLF_VI/', name, '_R444_8bpp.rgb'), 'w' );
            fwrite(fileID, views_rgb_imgVI(:, :, 1)', 'uint8');
            fclose(fileID);
            fileID = fopen( strcat(path, '4DLF_VI/', name, '_G444_8bpp.rgb'), 'w' );
            fwrite(fileID, views_rgb_imgVI(:, :, 2)', 'uint8');
            fclose(fileID);
            fileID = fopen( strcat(path, '4DLF_VI/', name, '_B444_8bpp.rgb'), 'w' );
            fwrite(fileID, views_rgb_imgVI(:, :, 3)', 'uint8');
            fclose(fileID);
            % YUV Actual writing
            fileID = fopen( strcat(path, '4DLF_VI/', name, '_YUV444_8bpp.yuv'), 'w' );
            fwrite(fileID, permute(views_yuv_imgVI, [2 1 3]), 'uint8');
            fclose(fileID);
            fileID = fopen( strcat(path, '4DLF_VI/', name, '_Y444_8bpp.yuv'), 'w' );
            fwrite(fileID, views_yuv_imgVI(:, :, 1)', 'uint8');
            fclose(fileID);
            fileID = fopen( strcat(path, '4DLF_VI/', name, '_U444_8bpp.yuv'), 'w' );
            fwrite(fileID, views_yuv_imgVI(:, :, 2)', 'uint8');
            fclose(fileID);
            fileID = fopen( strcat(path, '4DLF_VI/', name, '_V444_8bpp.yuv'), 'w' );
            fwrite(fileID, views_yuv_imgVI(:, :, 3)', 'uint8');
            fclose(fileID);
            % YUV Actual writing
            fileID = fopen( strcat(path, '4DLF_VI/', name, '_YUV420_8bpp.yuv'), 'w' );
            fwrite(fileID, views_yuv420_imgVI{1}', 'uint8');
            fwrite(fileID, views_yuv420_imgVI{2}', 'uint8');
            fwrite(fileID, views_yuv420_imgVI{3}', 'uint8');
            fclose(fileID);
            fileID = fopen( strcat(path, '4DLF_VI/', name, '_Y420_8bpp.yuv'), 'w' );
            fwrite(fileID, views_yuv420_imgVI{1}', 'uint8');
            fclose(fileID);
            fileID = fopen( strcat(path, '4DLF_VI/', name, '_U420_8bpp.yuv'), 'w' );
            fwrite(fileID, views_yuv420_imgVI{2}', 'uint8');
            fclose(fileID);
            fileID = fopen( strcat(path, '4DLF_VI/', name, '_V420_8bpp.yuv'), 'w' );
            fwrite(fileID, views_yuv420_imgVI{3}', 'uint8');
            fclose(fileID);
        end
    end
    
end

cd(img2use);
