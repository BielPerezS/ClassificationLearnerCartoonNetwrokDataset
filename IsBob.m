%% Bob Detector

% Carga de modelos y sus puntos válidos (debes tenerlos guardados)
load('BobEsponjaModelL1.mat');  % debe contener featuresL1 y validPointsL1
load('BobEsponjaModelL2.mat');
load('BobEsponjaModelL3.mat');
load('BobEsponjaModelL4.mat');
load('BobEsponjaModelL5.mat');
load('BobEsponjaModelLBack.mat');
load('BobEsponjaModelR1.mat');
load('BobEsponjaModelR2.mat');
load('BobEsponjaModelR3.mat');
load('BobEsponjaModelR4.mat');
load('BobEsponjaModelR5.mat');

modelim = {'L1.jpg','L2.jpg','L4.jpg','L5.jpg','LBack.jpg',...
           'R1.jpg','R2.jpg','R3.jpg','R4.jpg'};

feats = {featuresL1,featuresL2,featuresL4,featuresL5,featuresLBack,...
         featuresR1,featuresR2,featuresR3,featuresR4};

validPoints = {validPointsL1, validPointsL2, validPointsL4, validPointsL5, validPointsLBack, ...
               validPointsR1, validPointsR2, validPointsR3, validPointsR4, validPointsR5};

% Carga imagen de consulta
img2 = imread('./TRAIN/Bob esponja/SPONGE_BOB494.jpg');
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
if (TotalMatches >= 2)
    display("BOB HI ES");
end

