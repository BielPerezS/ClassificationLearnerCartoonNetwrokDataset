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
blueHistograms = zeros(numImages, numBins);

div_cell_size = 6;
cell_size = round(tamImage/div_cell_size);
tamresize = [tamImage, tamImage];



%disp(length(calcularAngulosHOG(zeros(numBins,numBins))));

%% FUNCIONS

function normalizedHog = calcularAngulosHOG(im, cellSize, fnumBins)
% calcularAngulosHOG - Calcula el ángulo medio de orientación HOG por bloque
%
% Sintaxis:
%   normalizedHog = calcularAngulosHOG(im, cellSize, numBins)
%
% Entradas:
%   im        - Imagen en escala de grises o RGB
%   cellSize  - Tamaño de celda, e.g., [64 64]
%   numBins   - Número de bins de orientación (e.g., 4, 8)
%
% Salida:
%   normalizedHog - Vector con los ángulos medios (en grados) por bloque
    if nargin < 2
        cellSize = [64 64];  % valor por defecto
    end
    if nargin < 3
        fnumBins = 8;
    end
    BlockSize = 4 * fnumBins;
    % Convertir a escala de grises si es necesario
    if size(im, 3) == 3
        im = rgb2gray(im);
    end
    % Extraer características HOG
    [featsVect, ~] = extractHOGFeatures(im, "CellSize", cellSize, "NumBins", fnumBins);
    numBloques = length(featsVect) / BlockSize;
    % Definir ángulos de los bins en radianes
    angleBins = linspace(0, pi, fnumBins + 1);
    angleBins = angleBins(1:end-1);  % quitar duplicado final
    % Inicializar vector resultado
    normalizedHog = zeros(1, numBloques);
    for i = 1:numBloques
        blockStart = (i-1)*BlockSize + 1;
        blockEnd = i*BlockSize;
        block = featsVect(blockStart:blockEnd);
        blockMatrix = reshape(block, [fnumBins, 4])';
        sumX = 0;
        sumY = 0;
        for c = 1:4
            for b = 1:fnumBins
                mag = blockMatrix(c, b);
                angle = angleBins(b);
                sumX = sumX + mag * cos(angle);
                sumY = sumY + mag * sin(angle);
            end
        end
        % Calcular ángulo medio
        meanAngle = atan2(sumY, sumX);
        if meanAngle < 0
            meanAngle = meanAngle + pi;
        end
        normalizedHog(i) = rad2deg(meanAngle);
    end
        
end

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
    % Construct full image path
        imgPath = fullfile(taula(i).folder, taula(i).name);
        
        % Read the image
        img = imread(imgPath);
        cropedIm = cropImage(img);
        
        imgres = imresize(cropedIm, tamresize, 'bilinear');

        % Extract R, G, B channels
        Red = uint8(imgres(:,:,1));
        Green = uint8(imgres(:,:,2));
        Blue = uint8(imgres(:,:,3));

        % Compute histograms
        redHistograms(i, :) = imhist(Red, numBins)';
        greenHistograms(i, :) = imhist(Green, numBins)';
        blueHistograms(i, :) = imhist(Blue, numBins)';

end

% Save histograms for later use (optional)
%%
save('RGB_NotNorm.mat', 'redHistograms', 'greenHistograms','blueHistograms', 'clase');

%%
load('RGB_NotNorm.mat');

%%
Feature = table(clase, greenHistograms, redHistograms, blueHistograms, ...
    'VariableNames', {'Class', 'GreenHisto','RedHisto', 'BlueHisto'});