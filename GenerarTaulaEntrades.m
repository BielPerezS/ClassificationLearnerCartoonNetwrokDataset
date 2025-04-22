%Insert path de TRAIN
taula = dir('F:\VC\Practica\TRAIN\**\*.jpg');
n = size(taula, 1);  % Get the number of files (rows)
taulares = struct('name', {}, 'Clase', {},'Test',{});  % Initialize an empty struct array

for i = 1 : n  % Start the loop at 1, since MATLAB indexing starts at 1
    type = -1;
    test = -1;

    if i >= 1 && i <= 131
        type = 0;
        diff = 131-1;
        if i < diff*0.7
            test = 0;
        else
            test = 1;
        end
    elseif i >= 132 && i <= 296
        type = 1;
        diff = 296-132;
        if i-132 < diff*0.7
            test = 0;
        else
            test = 1;
        end
    elseif i >= 297 && i <= 574
        type = 2;
        diff = 574-297;
        if i-297 < diff*0.7
            test = 0;
        else
            test = 1;
        end
    elseif i >= 575 && i <= 829
        type = 3;
        diff = 829-575;
        if i-575 < diff*0.7
            test = 0;
        else
            test = 1;
        end
    elseif i >= 830 && i <= 955
        type = 4;
        diff = 955-830;
        if i-830 < diff*0.7
            test = 0;
        else
            test = 1;
        end
    elseif i >= 956 && i <= 1093
        type = 5;
        diff = 1093-956;
        if i-956 < diff*0.7
            test = 0;
        else
            test = 1;
        end
    elseif i >= 1094 && i <= 1259
        type = 6;
        diff = 1259-1094;
        if i-1094 < diff*0.7
            test = 0;
        else
            test = 1;
        end
    elseif i >= 1260 && i <= 1379
        type = 7;
        diff = 1379-1260;
        if i-1260 < diff*0.7
            test = 0;
        else
            test = 1;
        end
    elseif i >= 1380 && i <= 1500
        type = 8;
        diff = 1500-1380;
        if i-1380 < diff*0.7
            test = 0;
        else
            test = 1;
        end
    elseif i >= 1501 && i <= 1564
        type = 9;
        diff = 1564-1501;
        if i-1501 < diff*0.7
            test = 0;
        else
            test = 1;
        end
    end
    
    % Add the file name and class type to the struct array
    taulares(i).name = horzcat(taula(i).folder,'/',taula(i).name);
    taulares(i).Clase = type;
    taulares(i).Test = test;
end
