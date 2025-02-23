function reconocerInstrumento()
    fig = uifigure('Name', 'Reconocer Instrumento', 'Position', [100, 100, 300, 200]);

    % Botón para cargar un archivo de audio
    btnArchivo = uibutton(fig, 'push', 'Text', 'Cargar Archivo', ...
        'Position', [50, 120, 100, 30], ...
        'ButtonPushedFcn', @(btn, event) cargarArchivo());

    % Botón para grabar desde el micrófono
    btnGrabar = uibutton(fig, 'push', 'Text', 'Grabar', ...
        'Position', [170, 120, 100, 30], ...
        'ButtonPushedFcn', @(btn, event) grabarDesdeMicrofono());

    % Etiqueta para mostrar el estado
    lblEstado = uilabel(fig, 'Text', 'Seleccione una opción.', ...
        'Position', [50, 80, 200, 30]);

    % Función para cargar un archivo de audio
    function cargarArchivo()
        close(fig); % Cerrar la figura actual
        [audioData, fs, audioSource, ~] = getAudioSource(0); % 0 para cargar archivo
        procesarAudio(audioData, fs);
    end

    % Función para grabar desde el micrófono
    function grabarDesdeMicrofono()
        fs = 44100; % Frecuencia de muestreo
        duration = 3; % Duración de la grabación en segundos

        % Crear el objeto audiorecorder
        recorder = audiorecorder(fs, 16, 1);

        % Ocultar la ventana del ícono rojo
        figIcono = findall(0, 'Type', 'Figure', 'Name', 'Recording');
        if ~isempty(figIcono)
            set(figIcono, 'Visible', 'off');
        end

        % Mostrar mensaje de grabación en la figura actual
        lblEstado.Text = 'Grabando audio...';

        % Iniciar la grabación
        record(recorder);

        % Esperar la duración de la grabación
        pause(duration);

        % Detener la grabación
        stop(recorder);

        % Obtener los datos de audio
        audioData = getaudiodata(recorder);

        % Cerrar la figura actual
        close(fig);

        % Procesar el audio
        procesarAudio(audioData, fs);
    end

    % Función para procesar el audio y reconocer el instrumento
    function procesarAudio(audioData, fs)
        global base_datos;

        % Procesar el audio para obtener características
        [~, ~, ~, harmonicIntensities, ~] = processAudio(audioData, fs);
        [A, D, S, R] = extractADSR(audioData, fs);

        % Reconocer el instrumento
        recognizedInstrument = recognizeInstrument(harmonicIntensities, [A, D, S, R], base_datos);

        % Mostrar el resultado
        if ~isempty(recognizedInstrument)
            uialert(uifigure, ['Instrumento reconocido: ' recognizedInstrument], 'Resultado');
        else
            uialert(uifigure, 'No se pudo reconocer el instrumento.', 'Error');
        end
    end
end