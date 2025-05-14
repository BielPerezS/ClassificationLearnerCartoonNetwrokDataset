% load TaulaEntrada.mat
% bob = imread("Bob esponja\SPONGE_BOB189.jpg");
% imshow(bob);
% 
% Red   = bob(:,:,1);
% Green = bob(:,:,2);
% Blue  = bob(:,:,3);
% 
% % Calcular la suma RGB como double
% sumRGB = double(Red) + double(Green) + double(Blue);
% 
% % Evitar división por cero: si la suma es 0, la cambiamos por 1
% sumRGB(sumRGB == 0) = 1;
% 
% % Canal verde normalizado (evita división por cero)
% GreenNorm = double(Green) ./ sumRGB;
% RedNorm = double(Red) ./ sumRGB;
% % Obtener histogramas
% [yRed, xRed]     = imhist(RedNorm, 256);
% [yGreen, xGreen] = imhist(GreenNorm, 256);  % for normalized green, specify bins
% 
% % Mostrar histogramas (opcional)
% figure;
% subplot(3,1,1); imhist(RedNorm, 256); title('Rojo Normalizar');
% subplot(3,1,2); imhist(GreenNorm, 256); title('Verde Normalizado');
% Load the table containing image paths

load('TaulaEntrada.mat'); % Assuming it contains a variable like 'imagePaths' or 'taula'
clase = TaulaEntrada(:,2);
%%
% Check the variable names in TaulaEntrada.mat
whos('-file', 'TaulaEntrada.mat'); % Debug: List variables in the .mat file

% If the table is named 'taula' and has a column 'folder' and 'name':
numImages = height(taula); % or length(taula) if it's a struct array
numBins = 256; % Number of bins for the histogram

% Initialize arrays to store histograms
redHistograms = zeros(numImages, numBins);
greenHistograms = zeros(numImages, numBins);

% Loop through each image
for i = 1:numImages
    % Construct full image path
    imgPath = fullfile(taula(i).folder, taula(i).name);
    
    % Read the image
    img = imread(imgPath);
    
    % Extract R, G, B channels
    Red = double(img(:,:,1));
    Green = double(img(:,:,2));
    Blue = double(img(:,:,3));
    
    % Compute normalized red and green
    sumRGB = Red + Green + Blue;
    sumRGB(sumRGB == 0) = 1; % Avoid division by zero
    
    RedNorm = Red ./ sumRGB;
    GreenNorm = Green ./ sumRGB;
    
    % Compute histograms
    redHistograms(i, :) = imhist(RedNorm, numBins)';
    greenHistograms(i, :) = imhist(GreenNorm, numBins)';
    
    % Optional: Display progress
    % fprintf('Processed image %d/%d: %s\n', i, numImages, taula(i).name);
end

% Save histograms for later use (optional)
%%
save('NormalizedHistograms.mat', 'redHistograms', 'greenHistograms', 'clase');

%%
load('NormalizedHistograms.mat');

%%
Feature = table(clase, greenHistograms, redHistograms, 'VariableNames', {'Class', 'GreenHisto','RedHisto'});

