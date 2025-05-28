load('TaulaEntrada.mat'); % Assuming it contains a variable like 'imagePaths' or 'taula'
clase = TaulaEntrada(:,2);
%% 
% Check the variable names in TaulaEntrada.mat
whos('-file', 'TaulaEntrada.mat'); % Debug: List variables in the .mat file

% If the table is named 'taula' and has a column 'folder' and 'name':
numImages = height(taula); % or length(taula) if it's a struct array
numBins = 64; % Number of bins for the histogram
tamImage = 256; 

% Initialize arrays to store histograms
redHistograms = zeros(numImages, numBins);
greenHistograms = zeros(numImages, numBins);

div_cell_size = 6;
cell_size = round(tamImage/div_cell_size);
tamresize = [tamImage, tamImage];

%disp(length(calcularAngulosHOG(zeros(numBins,numBins))));
%%
numCells = [2,2];

imgPath = fullfile(taula(1).folder, taula(1).name);   
% Read the image
img = imread(imgPath);



cropedIMG = cropImage(img);

figure, imshow(cropedIMG), title("imatge sene bandes negras");

grayOrig = rgb2gray(cropedIMG);

% Calculate dynamic cell size
cellSizeLBP = floor(size(grayOrig) ./ numCells);
% Ensure cellSize is at least 1x1
cellSizeLBP = max(cellSizeLBP, [1, 1]);

% Extract LBP
lbp = extractLBPFeatures(grayOrig, 'CellSize', cellSizeLBP);
longLBP = length(lbp);
lbpFeatures = zeros(numImages, longLBP);


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
numCells = [2,2];

for i = 1:numImages
    try    
    % Construct full image path
        imgPath = fullfile(taula(i).folder, taula(i).name);
        
        % Read the image
        img = imread(imgPath);
        cropedIm = cropImage(img);
        
        imgres = imresize(cropedIm, tamresize, 'bilinear');
        grayImg = rgb2gray(imgres); % HOG requires grayscale
        
        
        % === LBP on unresized image with dynamic CellSize ===
        grayOrig = rgb2gray(cropedIm);

        % Calculate dynamic cell size
        cellSizeLBP = floor(size(grayOrig) ./ numCells);
        % Ensure cellSize is at least 1x1
        cellSizeLBP = max(cellSizeLBP, [1, 1]);

        % Extract LBP
        lbp = extractLBPFeatures(grayOrig, 'CellSize', cellSizeLBP);

        % Preallocate on first iteration
        if i == 1
            lbpLength = length(lbp);
            lbpFeatures = zeros(numImages, lbpLength);
        end

        lbpFeatures(i, :) = lbp;
        
        % Extract R, G, B channels
        Red = double(imgres(:,:,1));
        Green = double(imgres(:,:,2));
        Blue = double(imgres(:,:,3));
        
        % Compute normalized red and green
        sumRGB = Red + Green + Blue;
        sumRGB(sumRGB == 0) = 1; % Avoid division by zero
        
        RedNorm = Red ./ sumRGB;
        GreenNorm = Green ./ sumRGB;
    
        % Compute histograms
        redHistograms(i, :) = imhist(RedNorm, numBins)';
        greenHistograms(i, :) = imhist(GreenNorm, numBins)';
    
    catch ME
        warning('Error processing image %d: %s', i, ME.message);
    end
end

% Save histograms for later use (optional)
%%
save('FeaturesRGBLBP.mat', 'redHistograms', 'greenHistograms','lbpFeatures', 'clase');

%%
load('FeaturesRGBLBP.mat');

%%
Feature = table(clase, greenHistograms, redHistograms, lbpFeatures, ...
    'VariableNames', {'Class', 'GreenHisto','RedHisto','LBPFeat'});