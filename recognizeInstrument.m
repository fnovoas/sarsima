function recognizedInstrument = recognizeInstrument(harmonicIntensities, base_datos)
    % recognizeInstrument: Compara los armónicos del audio actual con la base de datos
    % y devuelve el instrumento más parecido.
    %
    % Entradas:
    % - harmonicIntensities: Vector con las intensidades normalizadas de los armónicos.
    % - base_datos: Base de datos de instrumentos, con columnas:
    %   {Nombre del instrumento, Frecuencia fundamental, Datos de armónicos}.
    %
    % Salidas:
    % - recognizedInstrument: Nombre del instrumento reconocido.
    
    if isempty(base_datos)
        disp('La base de datos está vacía. Por favor, use el modo Grabar primero.');
        recognizedInstrument = '';
        return;
    end

    % Inicializar variables para encontrar el instrumento con menor error
    minError = Inf;
    recognizedInstrument = '';

    % Recorrer todos los instrumentos en la base de datos
    for i = 1:size(base_datos, 1)
        dbHarmonics = base_datos{i, 3}; % Obtener datos de armónicos del instrumento
        dbIntensities = dbHarmonics(:, 2); % Intensidades almacenadas en la base de datos

        % Calcular el error cuadrático medio (ECM) entre las intensidades
        error = mean((harmonicIntensities - dbIntensities').^2);

        % Si el error es menor al mínimo encontrado, actualizar
        if error < minError
            minError = error;
            recognizedInstrument = base_datos{i, 1};
        end
    end
end
