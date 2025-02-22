function recognizedInstrument = recognizeInstrument(harmonicIntensities, currentEnvelope, base_datos)
    % recognizeInstrument: Compara los armónicos y la envolvente ADSR del audio actual con la base de datos
    % y devuelve el instrumento más parecido.
    %
    % Entradas:
    % - harmonicIntensities: Vector con las intensidades normalizadas de los armónicos.
    % - currentEnvelope: Vector [A, D, S, R] con los parámetros de la envolvente del audio actual.
    % - base_datos: Base de datos de instrumentos, con columnas:
    %   {Nombre del instrumento, Frecuencia fundamental, Datos de armónicos, Envolvente}.
    %
    % Salidas:
    % - recognizedInstrument: Nombre del instrumento reconocido.

    if isempty(base_datos)
        disp('La base de datos está vacía. Por favor, use el modo Grabar primero.');
        recognizedInstrument = '';
        return;
    end

    minError = Inf;
    recognizedInstrument = '';

    % Definir un peso para el error de la envolvente (ajustable según se desee)
    lambda = 1;

    % Recorrer todos los instrumentos almacenados en la base de datos
    for i = 1:size(base_datos, 1)
        % Obtener datos de armónicos almacenados
        dbHarmonics = base_datos{i, 3};  % Matriz con [frecuencia, intensidad]
        dbIntensities = dbHarmonics(:, 2); % Intensidades

        % Calcular el error para los armónicos (error cuadrático medio)
        errorHarmonics = mean((harmonicIntensities - dbIntensities').^2);

        % Obtener la envolvente almacenada (si no existe, se asigna un valor por defecto)
        if size(base_datos, 2) >= 4
            dbEnvelope = base_datos{i, 4}; % [A, D, S, R]
        else
            dbEnvelope = [0.1, 0.2, 0.7, 0.5]; % Valores por defecto
        end

        % Convertir dbEnvelope a vector fila
        dbEnvelope = dbEnvelope(:)'; 
        if numel(dbEnvelope) ~= 4
            warning('El envelope del instrumento %s tiene un tamaño incorrecto. Se asignarán valores por defecto.', base_datos{i, 1});
            dbEnvelope = [0.1, 0.2, 0.7, 0.5];
        end
        % Calcular el error para la envolvente
        errorEnvelope = mean((currentEnvelope - dbEnvelope).^2);

        % Calcular el error total combinando ambos errores
        totalError = errorHarmonics + lambda * errorEnvelope;

        % Si el error total es menor que el mínimo encontrado, se actualiza el instrumento reconocido
        if totalError < minError
            minError = totalError;
            recognizedInstrument = base_datos{i, 1};
        end
    end
end
