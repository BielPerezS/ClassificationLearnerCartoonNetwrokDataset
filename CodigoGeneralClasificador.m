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

%% Cargamos el modelo

load('.\ClasificacionModelos\RgbLbp_Model.mat');
%%

img = imread("TRAIN\Bob esponja\SPONGE_BOB15396.jpg");

%%
% Number of bins for histograms
numBins = 64;
tamImage = 256;
tamresize = [tamImage, tamImage];

croppedImg = cropImage(img);
imgres = imresize(croppedImg, tamresize, 'bilinear');

% RGB Histograms
Red = double(imgres(:,:,1));
Green = double(imgres(:,:,2));
Blue = double(imgres(:,:,3));
sumRGB = Red + Green + Blue;
sumRGB(sumRGB == 0) = 1;
RedNorm = Red ./ sumRGB;
GreenNorm = Green ./ sumRGB;
redHist = imhist(RedNorm, numBins)';
greenHist = imhist(GreenNorm, numBins)';

% LBP Features
grayOrig = rgb2gray(croppedImg);
numCells = [2, 2];
cellSizeLBP = floor(size(grayOrig) ./ numCells);
cellSizeLBP = max(cellSizeLBP, [1, 1]);
lbp = extractLBPFeatures(grayOrig, 'CellSize', cellSizeLBP);

% Combine into one table row
feat = table(greenHist, lbp, redHist, ...
    'VariableNames', {'GreenHisto','LBPFeat','RedHisto'});

% Predict
predLabel = RgbLbp_Model.predictFcn(feat);
disp(predLabel);

%% 

if predLabel == 0 % BOB ESPONJAAAAAA

    % Carga de modelos y sus puntos válidos (debes tenerlos guardados)
    load('.\BobModels\BobEsponjaModelL1.mat');  % debe contener featuresL1 y validPointsL1
    load('.\BobModels\BobEsponjaModelL2.mat');
    load('.\BobModels\BobEsponjaModelL3.mat');
    load('.\BobModels\BobEsponjaModelL4.mat');
    load('.\BobModels\BobEsponjaModelL5.mat');
    load('.\BobModels\BobEsponjaModelLBack.mat');
    load('.\BobModels\BobEsponjaModelR1.mat');
    load('.\BobModels\BobEsponjaModelR2.mat');
    load('.\BobModels\BobEsponjaModelR3.mat');
    load('.\BobModels\BobEsponjaModelR4.mat');
    load('.\BobModels\BobEsponjaModelR5.mat');
    
    modelim = {'L1.jpg','L2.jpg','L4.jpg','L5.jpg','LBack.jpg',...
               'R1.jpg','R2.jpg','R3.jpg','R4.jpg'};
    
    feats = {featuresL1,featuresL2,featuresL4,featuresL5,featuresLBack,...
             featuresR1,featuresR2,featuresR3,featuresR4};
    
    validPoints = {validPointsL1, validPointsL2, validPointsL4, validPointsL5, validPointsLBack, ...
                   validPointsR1, validPointsR2, validPointsR3, validPointsR4, validPointsR5};
    
    % Carga imagen de consulta
    img2 = imread('./TRAIN/Bob esponja/SPONGE_BOB11773.jpg');
    gray2 = rgb2gray(img2);
    
    autoPoints2 = detectSIFTFeatures(gray2);  
    [features2, validPoints2] = extractFeatures(gray2, autoPoints2);
    
    TotalMatches = 0;
    for i = 1:length(feats)
        feature = feats{i};
        vp1 = validPoints{i}; % validPoints del modelo i
        
        indexPairs = matchFeatures(feature, features2, 'MatchThreshold', 5);
        matchedPoints1 = vp1(indexPairs(:,1));
        matchedPoints2 = validPoints2(indexPairs(:,2));
        
        numMatches = size(indexPairs, 1);
        
        if numMatches >= 1 
            TotalMatches = TotalMatches + 1;
        end    
        img1 = imread(fullfile('./SpongeBobModel', modelim{i}));
        
        figure;
        showMatchedFeatures(img1, img2, matchedPoints1, matchedPoints2, 'montage');
        title(sprintf('Matching con modelo %s', modelim{i}));
    end
    
    % Criteri De Decisió
    if (TotalMatches >= 4)
        disp("BOB HI ES");
    else
        disp("BOB NO HI ES");
    end

end

%% Percentatges de detecció de bob esponja:


% Carga de modelos y sus puntos válidos (debes tenerlos guardados)
load('.\BobModels\BobEsponjaModelL1.mat');  % debe contener featuresL1 y validPointsL1
load('.\BobModels\BobEsponjaModelL2.mat');
load('.\BobModels\BobEsponjaModelL3.mat');
load('.\BobModels\BobEsponjaModelL4.mat');
load('.\BobModels\BobEsponjaModelL5.mat');
load('.\BobModels\BobEsponjaModelLBack.mat');
load('.\BobModels\BobEsponjaModelR1.mat');
load('.\BobModels\BobEsponjaModelR2.mat');
load('.\BobModels\BobEsponjaModelR3.mat');
load('.\BobModels\BobEsponjaModelR4.mat');
load('.\BobModels\BobEsponjaModelR5.mat');

modelim = {'L1.jpg','L2.jpg','L4.jpg','L5.jpg','LBack.jpg',...
           'R1.jpg','R2.jpg','R3.jpg','R4.jpg'};

feats = {featuresL1,featuresL2,featuresL4,featuresL5,featuresLBack,...
         featuresR1,featuresR2,featuresR3,featuresR4};

validPoints = {validPointsL1, validPointsL2, validPointsL4, validPointsL5, validPointsLBack, ...
               validPointsR1, validPointsR2, validPointsR3, validPointsR4, validPointsR5};

table = dir("ImagenesBobEsponja\**\*.jpg");

nf = size(table);
tam = nf(1);
Episodio = strings(tam, 1);
Appears = -ones(tam, 1);
Test = zeros(tam, 1);

EncertsNegatiu = 0;
EncertsPositiu = 0;

for i = 1:tam
    Episodio(i) = table(i).name;

    folderPath = table(i).folder;

    if contains(folderPath, 'BobAppears')
        Appears(i) = 1;
    else
        Appears(i) = 0;
    end

    % ara a veure la nostra predicció

    imgPath = fullfile(table(i).folder, table(i).name);

    img = imread(imgPath);
    gray2 = rgb2gray(img);
    
    autoPoints2 = detectSIFTFeatures(gray2);  
    [features2, validPoints2] = extractFeatures(gray2, autoPoints2);
    
    TotalMatches = 0;
    for j = 1:length(feats)
        feature = feats{j};
        vp1 = validPoints{j}; % validPoints del modelo i
        
        indexPairs = matchFeatures(feature, features2, 'MatchThreshold', 5);
        matchedPoints1 = vp1(indexPairs(:,1));
        matchedPoints2 = validPoints2(indexPairs(:,2));
        
        numMatches = size(indexPairs, 1);
        
        if numMatches >= 1 
            TotalMatches = TotalMatches + 1;
        end    
        img1 = imread(fullfile('./SpongeBobModel', modelim{j}));
        
        %figure;
        %showMatchedFeatures(img1, img2, matchedPoints1, matchedPoints2, 'montage');
        %title(sprintf('Matching con modelo %s', modelim{i}));
    end
    
    % Criteri De Decisió
    if (TotalMatches >= 3)
        if Appears(i) == 1
            EncertsPositiu = EncertsPositiu + 1; 
        end
        %disp("BOB HI ES");
    else 
        if Appears(i) == 0
            EncertsNegatiu = EncertsNegatiu + 1; 
        end
        %disp("Bob no hi es");
    end

end

%%

disp("Positius Encertats: " + (EncertsPositiu/97)*100 + "%");
disp("Negatius Encertats: " + (EncertsNegatiu/34)*100 + "%");

