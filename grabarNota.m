function grabarNota()
    fig = uifigure('Name', 'Grabar Nota', 'Position', [100, 100, 300, 200]);

    % Botón para iniciar la grabación
    btnGrabar = uibutton(fig, 'push', 'Text', 'Iniciar Grabación', ...
        'Position', [50, 120, 200, 30], ...
        'ButtonPushedFcn', @(btn, event) iniciarGrabacion());

    % Etiqueta para mostrar el estado de la grabación
    lblEstado = uilabel(fig, 'Text', 'Presiona "Iniciar Grabación" para comenzar.', ...
        'Position', [50, 80, 200, 30]);

    % Variable para almacenar los datos de audio
    audioData = [];
    fs = 44100; % Frecuencia de muestreo

    % Función para iniciar la grabación
    function iniciarGrabacion()
        % Crear el objeto audiorecorder
        recorder = audiorecorder(fs, 16, 1);

        % Ocultar la ventana del ícono rojo
        figIcono = findall(0, 'Type', 'Figure', 'Name', 'Recording');
        if ~isempty(figIcono)
            set(figIcono, 'Visible', 'off');
        end

        % Actualizar la etiqueta
        lblEstado.Text = 'Grabando...';

        % Iniciar la grabación
        record(recorder);

        % Esperar 3 segundos (duración de la grabación)
        pause(3);

        % Detener la grabación
        stop(recorder);
        lblEstado.Text = 'Grabación finalizada.';

        % Obtener los datos de audio
        audioData = getaudiodata(recorder);

        % Pedir nombre del instrumento
        answer = inputdlg('Ingrese el nombre del instrumento:', 'Nombre del Instrumento', [1 50]);
        if isempty(answer)
            uialert(fig, 'No ingresó un nombre. Operación cancelada.', 'Error');
            return;
        end
        instrumentName = answer{1};

        % Procesar el audio y guardar en la base de datos
        [freq, fftMagnitude, fundamentalFreq, harmonicIntensities, harmonics] = processAudio(audioData, fs);
        [A, D, S, R] = extractADSR(audioData, fs);
        saveToDatabase(instrumentName, fundamentalFreq, harmonics, harmonicIntensities, [A, D, S, R]);

        % Mostrar mensaje de éxito
        uialert(fig, 'Nota grabada y guardada.', 'Éxito');
    end
end