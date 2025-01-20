function saveToDatabase(instrumentName, fundamentalFreq, harmonics, harmonicIntensities)
    global base_datos;

    % Formatear intensidades a 10 cifras decimales
    harmonicIntensities = arrayfun(@(x) str2double(sprintf('%.10f', x)), harmonicIntensities);

    % Crear un registro de armónicos con sus frecuencias e intensidades
    harmonicData = [harmonics; harmonicIntensities]';

    % Verificar si el instrumento ya está en la base de datos
    found = false;
    for i = 1:size(base_datos, 1)
        if strcmp(base_datos{i, 1}, instrumentName)
            base_datos{i, 2} = fundamentalFreq; % Actualizar frecuencia fundamental
            base_datos{i, 3} = harmonicData; % Actualizar datos de armónicos
            found = true;
            break;
        end
    end

    if ~found
        % Agregar nuevo instrumento
        base_datos = [base_datos; {instrumentName, fundamentalFreq, harmonicData}];
    end

    % Guardar la base de datos en un archivo
    save('harmonic_db.mat', 'base_datos');
    disp('Base de datos actualizada y guardada.');
end