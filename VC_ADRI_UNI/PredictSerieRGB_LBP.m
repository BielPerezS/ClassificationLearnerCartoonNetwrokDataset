% Load the trained model
load('LBP_RGBModel.mat');  % Assumes variable name is LBP_RGBModel
%%
d = dir(".\ImagenesExternasPrueba\GatIGos_prueba2.jpg");


imgPath = fullfile(d.folder,d.name);

img = imread(imgPath);

% Crop dark side bands
croppedImg = cropImage(img);

% Resize for RGB histograms
tamImage = 256;
tamresize = [tamImage, tamImage];
imgres = imresize(croppedImg, tamresize, 'bilinear');

% ----- Extract Color Histograms (Red and Green Normalized) -----
numBins = 64;
Red = double(imgres(:,:,1));
Green = double(imgres(:,:,2));
Blue = double(imgres(:,:,3));
sumRGB = Red + Green + Blue;
sumRGB(sumRGB == 0) = 1;  % Avoid division by zero
RedNorm = Red ./ sumRGB;
GreenNorm = Green ./ sumRGB;
redHist = imhist(RedNorm, numBins)';
greenHist = imhist(GreenNorm, numBins)';

% ----- Extract LBP Features -----
grayOrig = rgb2gray(croppedImg);
numCells = [2, 2];
cellSizeLBP = floor(size(grayOrig) ./ numCells);
cellSizeLBP = max(cellSizeLBP, [1, 1]);  % Ensure size is valid
lbp = extractLBPFeatures(grayOrig, 'CellSize', cellSizeLBP);

% ----- Combine Features -----

Feature = table(greenHist, lbp, redHist, ...
    'VariableNames', {'GreenHisto','LBPFeat','RedHisto'});

% ----- Predict Class -----
AAA = LBP_RGBModel.predictFcn(Feature);
fprintf("clase: %d\n", AAA);
% Display result

%% --- Helper Function ---
function [croppedImg] = cropImage(img)
    hsvImg = rgb2hsv(img);
    valueThreshold = 0.3;
    darkMask = hsvImg(:,:,3) < valueThreshold;
    colDarkPercent = mean(darkMask, 1);
    nonBarCols = colDarkPercent < 0.9;
    firstCol = find(nonBarCols, 1, 'first');
    lastCol = find(nonBarCols, 1, 'last');
    if isempty(firstCol) || isempty(lastCol) || firstCol >= lastCol
        warning('Could not detect valid crop region - returning original image');
        croppedImg = img;
        return;
    end
    firstCol = max(1, firstCol);
    lastCol = min(size(img, 2), lastCol);
    croppedImg = img(:, firstCol:lastCol, :);
end

%%
class(LBP_RGBModel)