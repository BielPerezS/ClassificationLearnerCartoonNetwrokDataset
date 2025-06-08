load('TaulaEntrada.mat'); % Assuming it contains a variable like 'imagePaths' or 'taula'
clase = TaulaEntrada(:,2);
%% 
% Check the variable names in TaulaEntrada.mat
whos('-file', 'TaulaEntrada.mat'); % Debug: List variables in the .mat file

% If the table is named 'taula' and has a column 'folder' and 'name':
numImages = height(taula); % or length(taula) if it's a struct array
numBins = 64; % Number of bins for the histogram
tamImage = 256; 

div_cell_size = 4;
cell_size = round(tamImage/div_cell_size);
tamresize = [tamImage, tamImage];

% Preallocate feature matrix (you can estimate HOG length from one sample)
sampleImg = imread(fullfile(taula(1).folder, taula(1).name));
sampleImg = cropImage(sampleImg);
sampleImg = imresize(sampleImg, tamresize);
[hogFeature, ~] = extractHOGFeatures(rgb2gray(sampleImg), 'CellSize', [cell_size, cell_size]); 
hogLength = length(hogFeature);

% Preallocate feature storage
hogFeatures = zeros(numImages, hogLength);

%disp(length(calcularAngulosHOG(zeros(numBins,numBins))));

%% FUNCIONS

function [croppedImg] = cropImage(img)
    hsvImg = rgb2hsv(img);
    
    % Create mask based on value (brightness) channel
    valueThreshold = 0.3; % Adjust as needed (0-1 range)
    darkMask = hsvImg(:,:,3) < valueThreshold;
    
    % Find columns that are mostly dark (>90% dark pixels)
    colDarkPercent = mean(darkMask, 1);
    nonBarCols = colDarkPercent < 0.9; % Columns to keep
    
    % Find first and last non-bar columns
    firstCol = find(nonBarCols, 1, 'first');
    lastCol = find(nonBarCols, 1, 'last');
    
    % Validate the cropping indices
    if isempty(firstCol) || isempty(lastCol) || firstCol >= lastCol
        warning('Could not detect valid crop region - returning original image');
        croppedImg = img;
        return;
    end
    
    % Adjust indices with boundary checks
    firstCol = max(1, firstCol);
    lastCol = min(size(img, 2), lastCol);
    
    % Crop the image (removed the +1/-1 adjustment)
    croppedImg = img(:, firstCol:lastCol, :);
end% Display and sav

%%
% Loop through each image
for i = 1:numImages
    try    
    % Construct full image path
        imgPath = fullfile(taula(i).folder, taula(i).name);
        
        % Read the image
        img = imread(imgPath);
        cropedIm = cropImage(img);
        
        imgres = imresize(cropedIm, tamresize, 'bilinear');
        grayImg = rgb2gray(imgres); % HOG requires grayscale
        
        % Extract HOG
        hogFeatures(i, :) = extractHOGFeatures(grayImg, 'CellSize', [cell_size,cell_size]);
        % Compute histograms
    
    catch ME
        warning('Error processing image %d: %s', i, ME.message);
        hogFeatures(i, :) = NaN; % Fill with NaNs on error
    end
end

% Save histograms for later use (optional)
%%
save('HOG_HISTO.mat', "hogFeatures", 'clase');

%%
load('HOG_HISTO.mat');

%%
Feature = table(clase.Class, hogFeatures, ...
    'VariableNames', {'Class', 'HogHist'});