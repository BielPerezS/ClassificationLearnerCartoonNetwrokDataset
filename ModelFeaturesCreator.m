%% Posar punts model

img1 = imread('./SpongeBobModel/L1.jpg');
figure,imshow(img1);
title('Select keypoints on Image 1');
[L1kp_x1, L1kp_y1] = ginput;  
L1kp = [L1kp_x1, L1kp_y1];

gray1 = rgb2gray(img1);
autoPoints1 = detectSIFTFeatures(gray1);

% Agafem el punt de autopoints mes proper al seleccionat manualment
numManual = size(L1kp, 1);
assignedScale = zeros(numManual, 1);
assignedOrientation = zeros(numManual, 1);
assignedOctave = zeros(numManual, 1);
assignedLayer = zeros(numManual, 1);

for i = 1:numManual
    distances = vecnorm(autoPoints1.Location - L1kp(i,:), 2, 2);
    [~, idxClosest] = min(distances);
    assignedScale(i) = autoPoints1.Scale(idxClosest);
    assignedOrientation(i) = autoPoints1.Orientation(idxClosest);
    assignedOctave(i) = autoPoints1.Octave(idxClosest);
    assignedLayer(i) = autoPoints1.Layer(idxClosest);
end

manualPoints = SIFTPoints(L1kp, ...
    'Scale', assignedScale, ...
    'Orientation', assignedOrientation, ...
    'Octave', assignedOctave, ...
    'Layer', assignedLayer);

[featuresL1, validPointsL1] = extractFeatures(gray1, manualPoints);

save('BobEsponjaModelL1.mat', 'featuresL1',"validPointsL1");


%% Show kp img 1

figure,imshow(img1); hold on;
plot(L1kp_x1, L1kp_y1, 'ro', 'MarkerSize', 5, 'LineWidth', 2);
