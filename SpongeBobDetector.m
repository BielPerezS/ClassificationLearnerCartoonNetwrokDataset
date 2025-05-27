im = imread("./SpongeBobModel/SPONGE_BOB6813.jpg");
imshow(im);

%% Harris?

im = rgb2gray(im);
corners = detectHarrisFeatures(im);
imshow(im), title("corners");
hold on
plot(corners);

%% SIFT

%Imatge model a comparar
imModel = rgb2gray(imread("./SpongeBobModel/SPONGE_BOB6813.jpg"));
kp_model = detectSIFTFeatures(imModel);
figure,imshow(imModel),title("Model");
hold on
plot(selectStrongest(kp_model,100));

%Imatge a testejar segons el matching
imTest = rgb2gray(imread("./TRAIN/Bob esponja/SPONGE_BOB493.jpg"));
kp_test =  detectSIFTFeatures(imTest);
figure,imshow(imTest),title("Test");
hold on
plot(selectStrongest(kp_test,100));

[feat_model, kp_model] = extractFeatures(imModel, kp_model);
[feat_test, kp_test] = extractFeatures(imTest, kp_test);
pairs = matchFeatures(feat_model, feat_test, "MatchThreshold", 10);
matched_kp_model = kp_model(pairs(:,1),:);
matched_kp_test = kp_test(pairs(:,2),:);
figure,showMatchedFeatures(imModel, imTest, matched_kp_model, matched_kp_test,"montage");
title("aparellaments putatius");

%    [tform, truepos] = estimateGeometricTransform2D(matched_kp_model,matched_kp_test,"affine");
%    true_kp_model=matched_kp_model(truepos,:);
%    true_kp_test=matched_kp_test(truepos,:);
%    figure,showMatchedFeatures(imModel,imTest, true_kp_model, true_kp_test, "montage"),title("true matches");


%% Idea

detecat keypoints amb harris.  fer DESCRITORS de keypoins amb sift.
matching?

%% V2
% Imagen modelo
imModel = rgb2gray(imread("./SpongeBobModel/SPONGE_BOB6813.jpg"));
corners_model = detectSIFTFeatures(imModel);
[feat_model, valid_corners_model] = extractFeatures(imModel, corners_model, 'Method', 'SIFT');

% Imagen test
imTest = rgb2gray(imread("./TRAIN/Bob esponja/SPONGE_BOB572.jpg"));
corners_test = detectSIFTFeatures(imTest);
[feat_test, valid_corners_test] = extractFeatures(imTest, corners_test, 'Method', 'SIFT');

% Matching
[pairs, matchMetric] = matchFeatures(feat_model, feat_test, "MatchThreshold", 10);
matched_model = valid_corners_model(pairs(:,1));
matched_test = valid_corners_test(pairs(:,2));

% Mostrar todos los matches
figure;
showMatchedFeatures(imModel, imTest, matched_model, matched_test, "montage");
title("Matching inicial");

% RANSAC para filtrar outliers
[tform, inlierIdx] = estimateGeometricTransform2D(matched_model, matched_test, 'affine');
inlier_model = matched_model(inlierIdx);
inlier_test = matched_test(inlierIdx);

% Mostrar solo inliers
figure;
showMatchedFeatures(imModel, imTest, inlier_model, inlier_test, "montage");
title("Matching amb inliers (RANSAC)");

% Extraer vector de características
numMatches = size(pairs,1);
numInliers = sum(inlierIdx);

if numInliers > 0
    dists = vecnorm(inlier_model.Location - inlier_test.Location, 2, 2);
    meanDist = mean(dists);
    stdDist = std(dists);
else
    meanDist = 0;
    stdDist = 0;
end

inlierRatio = numInliers / max(numMatches, 1);  % evitar división por 0

%Atencio modular cellsize segons la resolucio que s'utilitzara
hogFeatures = extractHOGFeatures(imTest,"CellSize",[64 64],"NumBins",9);
% Crear vector de características
features = [numMatches, numInliers, inlierRatio, meanDist, stdDist,hogFeatures];

% Asignar etiqueta (por ejemplo, 1 si es Bob Esponja, 0 si no)
label = 1;

% Guardar para usar con Classification Learner
% --> Puedes repetir esto en un bucle para varias imágenes

T = array2table(features, 'VariableNames', {'TotalMatches','Inliers','InlierRatio','MeanDist','StdDist','HogFeatures'});
T.Label = label;

%Classificar imatges en si SURT BOB ESPONJA o no

%% Modo Loop

