
%taula = dir('I:\vc\sample images\**\*.jpg');
%nf = size(taula);

%1r fer taula: 30 serà de test y la resta de aprenen
%2n: extreure caracteristiques, exemple de posibles vectors de
%caracteristiques:
    % Histograma de colors podria ser una caracteristica
%3r: etapa de aprenentatge

taula = dir("C:\Users\adria.cebrian\Downloads\TRAIN\TRAIN\**\*.jpg");
nf = size(taula);
tam = nf(1);

Episodio = strings;
Serie = ones;
%Test = ones(1);

for i = 1:tam
    Episodio(i) = taula(i).name;
    folderPath = taula(i).folder;
    
    % Use strcmpi for case-insensitive comparison (safer)
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

TaulaEntrada = struct("Episodeo" , Episodio, "Clas", Serie)
%}
