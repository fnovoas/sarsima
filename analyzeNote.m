function analyzeNote()
    % Inicializar la base de datos
    global base_datos;
    base_datos = initializeDatabase();

    % Seleccionar modo: grabar, reconocer o sintetizar
    mode = selectMode();

    if mode == 0
        % Modo Grabar: Guardar en la base de datos
        % Obtener la fuente de audio
        [audioData, fs, audioSource, instrumentName] = getAudioSource();

        % Procesar el audio para obtener resultados
        [freq, fftMagnitude, fundamentalFreq, harmonicIntensities, harmonics] = processAudio(audioData, fs);

        % Mostrar resultados
        fprintf('Frecuencia Fundamental: %.2f Hz\n', fundamentalFreq);
        fprintf('Armónicos y sus intensidades:\n');
        for i = 1:length(harmonics)
            if i == 1
                % Para el primer armónico
                fprintf('Armónico %d: %.2f Hz con %.0f%% de intensidad\n', i, harmonics(i), harmonicIntensities(i));
            else
                % Para los demás armónicos
                fprintf('Armónico %d: %.2f Hz con %.10f%% de intensidad\n', i, harmonics(i), harmonicIntensities(i));
            end
        end

        % Guardar en la base de datos
        saveToDatabase(instrumentName, fundamentalFreq, harmonics, harmonicIntensities);

        % Graficar los resultados al final
        plotResults(freq, fftMagnitude, harmonicIntensities, harmonics, audioSource);

    elseif mode == 1
        % Modo Reconocer: Comparar con la base de datos
        % Obtener la fuente de audio
        [audioData, fs, audioSource, ~] = getAudioSource();

        % Procesar el audio para obtener resultados
        [~, ~, ~, harmonicIntensities, ~] = processAudio(audioData, fs);

        % Reconocer instrumento
        recognizedInstrument = recognizeInstrument(harmonicIntensities, base_datos);
        if ~isempty(recognizedInstrument)
            fprintf('El instrumento reconocido es: %s\n', recognizedInstrument);
        else
            disp('No se pudo reconocer el instrumento.');
        end

    elseif mode == 2
        % Modo Sintetizar: Crear y guardar un nuevo instrumento
        synthesizeInstrument();

    else
        disp('Modo no reconocido.');
    end
end