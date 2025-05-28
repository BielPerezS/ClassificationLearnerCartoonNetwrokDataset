% Load the input table
load('TaulaEntrada.mat'); % Assuming it contains a variable like 'imagePaths' or 'taula'
clase = TaulaEntrada(:,2);
%% 
% Check the variable names in TaulaEntrada.mat
whos('-file', 'TaulaEntrada.mat'); % Debug: List variables in the .mat file

% Parameters
numImages = height(taula); 
tamImage = 256; 
numBins = 64;

div_cell_size = 8;
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

%%
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

%% Loop through each image and extract HOG
for i = 1:numImages
    try
        imgPath = fullfile(taula(i).folder, taula(i).name);
        img = imread(imgPath);
        
        % Preprocessing
        img = cropImage(img); % Assume this function is defined
        img = imresize(img, tamresize, 'bilinear');
        grayImg = rgb2gray(img); % HOG requires grayscale
        
        % Extract HOG
        hogFeatures(i, :) = extractHOGFeatures(grayImg, 'CellSize', [cell_size,cell_size]);
    catch ME
        warning('Error processing image %d: %s', i, ME.message);
        hogFeatures(i, :) = NaN; % Fill with NaNs on error
    end
end

%% Create a table with features
Feature = array2table(hogFeatures);
Feature.Label = clase;

% Save the feature table
save('HOG_Features.mat', 'Feature');

%%

load('HOG_Features.mat')
