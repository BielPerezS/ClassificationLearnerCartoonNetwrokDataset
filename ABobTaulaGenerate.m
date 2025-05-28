taula = dir(".\SpongeBobModel\IsBob\**\*.jpg"); %Windows
% taula = dir("./**/TRAIN*.jpg");  % Alternative for cross-platform

nf = size(taula);
tam = nf(1);

Episodio = strings(tam, 1);
Appears = -ones(tam, 1);
Test = zeros(tam, 1);
%1 == Testing
%0 == Learning

for i = 1:tam
    Episodio(i) = taula(i).name;

    folderPath = taula(i).folder;

    if contains(folderPath, 'BobAppears')
        Appears(i) = 1;
    else
        Appears(i) = 0;
    end

end

SpongeBobFinder = table(Episodio, Appears, 'VariableNames', {'Episodeo', 'Class'});
save('SpongeBobFinder.mat', 'SpongeBobFinder');