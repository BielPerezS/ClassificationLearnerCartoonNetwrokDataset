%% Load data and prepare
load('TaulaEntrada.mat');
clase = TaulaEntrada(:,2);
numImages = height(taula);
tamImage = 256;
tamresize = [tamImage, tamImage];
numBins = 64;

redHistograms = zeros(numImages, numBins);
greenHistograms = zeros(numImages, numBins);

%% Functions

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

%% Extract SIFT descriptors from all images
allDescriptors = [];

for i = 1:numImages
    try
        img = imread(fullfile(taula(i).folder, taula(i).name));
        img = cropImage(img);
        img = imresize(img, tamresize);
        grayImg = rgb2gray(img);

        % Detect and extract SIFT features
        points = detectSIFTFeatures(grayImg);
        [features, ~] = extractFeatures(grayImg, points);

        % Collect all descriptors for BoVW clustering
        allDescriptors = [allDescriptors; double(features)];

    catch ME
        warning('Image %d failed during SIFT collection: %s', i, ME.message);
    end
end

%% Build Visual Vocabulary (K-Means)
numClusters = 100; % Try 50-200 depending on data
[~, visualVocab] = kmeans(allDescriptors, numClusters, 'MaxIter', 500);

%% Represent each image using BoVW histogram
siftHistograms = zeros(numImages, numClusters);

for i = 1:numImages
    try
        img = imread(fullfile(taula(i).folder, taula(i).name));
        img = cropImage(img);
        img = imresize(img, tamresize);
        grayImg = rgb2gray(img);

        % SIFT
        points = detectSIFTFeatures(grayImg);
        [features, ~] = extractFeatures(grayImg, points);

        % Assign to nearest cluster
        if isempty(features)
            continue;
        end
        distances = pdist2(double(features), visualVocab);
        [~, assignments] = min(distances, [], 2);
        siftHist = histcounts(assignments, 1:(numClusters+1));
        siftHistograms(i, :) = siftHist / sum(siftHist); % Normalize

        % RGB Normalized Histogram (Red & Green only)
        Red = double(img(:,:,1));
        Green = double(img(:,:,2));
        Blue = double(img(:,:,3));
        sumRGB = Red + Green + Blue;
        sumRGB(sumRGB == 0) = 1;

        RedNorm = Red ./ sumRGB;
        GreenNorm = Green ./ sumRGB;

        redHistograms(i, :) = imhist(RedNorm, numBins)';
        greenHistograms(i, :) = imhist(GreenNorm, numBins)';

    catch ME
        warning('Error processing image %d: %s', i, ME.message);
    end
end

%% Save for classification
save('SIFT_Histograms.mat', 'redHistograms', 'greenHistograms', 'siftHistograms', 'clase');

%% Load & build final feature table
load('SIFT_Histograms.mat');

Feature = table(clase, greenHistograms, redHistograms, siftHistograms, ...
    'VariableNames', {'Class', 'GreenHisto','RedHisto', 'SIFTHisto'});
