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
numBins = 64; % Still using 64-bin histograms
labHistograms = zeros(numImages, numBins * 2); % a* and b* histograms
numCells = [2,2];
for i = 1:numImages
    try
        % Construct full image path
        imgPath = fullfile(taula(i).folder, taula(i).name);
        img = imread(imgPath);

        % Crop and resize
        croppedImg = cropImage(img);
        imgres = imresize(croppedImg, tamresize);

        %LBP =================
        grayOrig = rgb2gray(croppedImg);

        % Calculate dynamic cell size
        cellSizeLBP = floor(size(grayOrig) ./ numCells);
        % Ensure cellSize is at least 1x1
        cellSizeLBP = max(cellSizeLBP, [1, 1]);

        % Extract LBP
        lbp = extractLBPFeatures(grayOrig, 'CellSize', cellSizeLBP);

        lbpFeatures(i, :) = lbp;


        % Convert to LAB
        labImg = rgb2lab(imgres); % MATLAB’s built-in function

        % Separate LAB channels
        L = labImg(:,:,1);  % Lightness (0 to 100)
        a = labImg(:,:,2);  % Green–Red (-128 to 127)
        b = labImg(:,:,3);  % Blue–Yellow (-128 to 127)

        % Normalize a* and b* to [0,1] for histogram calculation
        a_norm = (a + 128) / 255; 
        b_norm = (b + 128) / 255;

        % Compute histograms (you could also include L if needed)
        a_hist = imhist(a_norm, numBins)';
        b_hist = imhist(b_norm, numBins)';

        % Store concatenated histogram
        labHistograms(i, :) = [a_hist, b_hist];

    catch ME
        warning('Error processing image %d: %s', i, ME.message);
        labHistograms(i, :) = NaN;
    end
end


% Save histograms for later use (optional)
%%
save('FeaturesLAB.mat', 'labHistograms', 'lbpFeatures','clase');

%%
load('FeaturesLAB.mat');

%%
Feature = table(clase, labHistograms, lbpFeatures,...
    'VariableNames', {'Class', 'LabHisto', 'LBPFeatures'});