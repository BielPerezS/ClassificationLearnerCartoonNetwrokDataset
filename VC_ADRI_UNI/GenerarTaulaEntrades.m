%taula = dir('I:\vc\sample images**.jpg');
%nf = size(taula);

%1r fer taula: 30 serà de test y la resta de aprenen
%2n: extreure caracteristiques, exemple de posibles vectors de
%caracteristiques:
    % Histograma de colors podria ser una caracteristica
%3r: etapa de aprenentatge

% taula = dir(".\TRAIN\**\*.jpg"); %Windows
taula = dir(".\TRAIN\*\*.jpg");  % Alternative for cross-platform

nf = size(taula);
tam = nf(1);

Episodio = strings(tam, 1);
Serie = -ones(tam, 1);
Test = zeros(tam, 1);
%1 == Testing
%0 == Learning

for i = 1:tam
    Episodio(i) = taula(i).name;

    random = rand();
    % rand() devuelve un random [0,1]

    if random < 0.30
        Test(i) = 1;
    end

    folderPath = taula(i).folder;

    if contains(folderPath, 'Bob esponja')
        Serie(i) = 0;
    elseif contains(folderPath, 'Gumball')
        Serie(i) = 1;
    elseif contains(folderPath, 'Oliver y Benji')
        Serie(i) = 2;
    elseif contains(folderPath, 'Tom y Jerry')
        Serie(i) = 3;
    elseif contains(folderPath, 'barrufets')
        Serie(i) = 4;
    elseif contains(folderPath, 'gat i gos')
        Serie(i) = 5;
    elseif contains(folderPath, 'hora de aventuras')
        Serie(i) = 6;
    elseif contains(folderPath, 'padre de familia')
        Serie(i) = 7;
    elseif contains(folderPath, 'pokemon')
        Serie(i) = 8;
    elseif contains(folderPath, 'southpark')
        Serie(i) = 9;
    end

end

TaulaEntrada = table(Episodio, Serie, Test, 'VariableNames', {'Episodeo', 'Class','Test'});
save('TaulaEntrada.mat', 'TaulaEntrada');
