function [audioData, fs, audioSource, instrumentName] = getAudioSource()
    % Seleccionar fuente de audio
    disp('Seleccione una fuente de audio:');
    disp('1: Grabar audio con el micrófono.');
    disp('0: Cargar un archivo de audio existente.');
    option = input('Ingrese su opción (1 o 0): ');

    while option ~= 1 && option ~= 0
        disp('Opción no válida. Por favor, ingrese 1 o 0.');
        option = input('Ingrese su opción (1 o 0): ');
    end

    fs = 44100; % Frecuencia de muestreo
    duration = 3; % Duración en segundos

    if option == 1
        % Grabar audio desde el micrófono
        disp('Grabando audio desde el micrófono...');
        recorder = audiorecorder(fs, 16, 1);
        recordblocking(recorder, duration);
        audioData = getaudiodata(recorder);

        % Verificar duración
        if length(audioData) < fs * 2
            disp('El audio grabado debe durar al menos 2 segundos. Intente nuevamente.');
            audioData = [];
            audioSource = '';
            instrumentName = '';
            return;
        elseif length(audioData) < fs * duration
            % Rellenar con silencio si dura entre 2 y 3 segundos
            disp('El audio tiene menos de 3 segundos. Rellenando con silencio...');
            audioData = [audioData; zeros(fs * duration - length(audioData), 1)];
        end

        % Asegurarse de usar solo los primeros 3 segundos
        audioData = audioData(1:fs * duration);
        disp('Grabación completa.');
        audioSource = 'Nota grabada';
        instrumentName = input('Ingrese el nombre del instrumento correspondiente a la grabación: ', 's');

    else
        % Cargar archivo de audio
        [fileName, pathName] = uigetfile({'*.wav;*.mp3', 'Archivos de audio (*.wav, *.mp3)'});
        if isequal(fileName, 0)
            disp('No se seleccionó ningún archivo. Saliendo del programa.');
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
            disp('El audio cargado debe durar al menos 2 segundos. Intente nuevamente.');
            audioData = [];
            audioSource = '';
            instrumentName = '';
            return;
        elseif length(audioData) < fs * duration
            % Rellenar con silencio si dura entre 2 y 3 segundos
            disp('El audio tiene menos de 3 segundos. Rellenando con silencio...');
            audioData = [audioData; zeros(fs * duration - length(audioData), 1)];
        end

        % Usar solo los primeros 3 segundos
        audioData = audioData(1:fs * duration);
        disp(['Archivo ', fileName, ' cargado correctamente.']);
        audioSource = fileName;
        [~, instrumentName, ~] = fileparts(fileName); % Obtener nombre del instrumento
    end
end