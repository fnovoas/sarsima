function [audioData, fs, audioSource, instrumentName] = getAudioSource(option)
    fs = 44100; % Frecuencia de muestreo
    duration = 3; % Duración en segundos

    if option == 1
        % Grabar audio desde el micrófono (ya no se usa aquí)
        error('La grabación desde el micrófono debe manejarse en grabarNota.m');
    else
        % Cargar archivo de audio
        [fileName, pathName] = uigetfile({'*.wav;*.mp3', 'Archivos de audio (*.wav, *.mp3)'});
        if isequal(fileName, 0)
            uialert(uifigure, 'No se seleccionó ningún archivo. Operación cancelada.', 'Error');
            audioData = [];
            audioSource = '';
            instrumentName = '';
            return;
        end

        audioFile = fullfile(pathName, fileName);
        [audioData, fs] = audioread(audioFile);
        audioData = mean(audioData, 2); % Convertir a mono si es estéreo

        % Verificar duración
        if length(audioData) < fs * 2
            uialert(uifigure, 'El audio cargado debe durar al menos 2 segundos. Intente nuevamente.', 'Error');
            audioData = [];
            audioSource = '';
            instrumentName = '';
            return;
        elseif length(audioData) < fs * duration
            % Rellenar con silencio si dura entre 2 y 3 segundos
            audioData = [audioData; zeros(fs * duration - length(audioData), 1)];
        end

        % Usar solo los primeros 3 segundos
        audioData = audioData(1:fs * duration);
        audioSource = fileName;
        [~, instrumentName, ~] = fileparts(fileName); % Obtener nombre del instrumento
    end
end