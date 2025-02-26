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
    
        % Procesar el audio para obtener resultados (armónicos, etc.)
        [freq, fftMagnitude, fundamentalFreq, harmonicIntensities, harmonics] = processAudio(audioData, fs);
    
        % Mostrar resultados de los armónicos
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
    
        % Extraer parámetros ADSR automáticamente a partir de la señal grabada
        [A, D, S, R] = extractADSR(audioData, fs);
        fprintf('Parámetros ADSR extraídos:\n');
        fprintf('  Ataque (A): %.2f s\n', A);
        fprintf('  Decaimiento (D): %.2f s\n', D);
        fprintf('  Sostenimiento (S): %.2f\n', S);
        fprintf('  Liberación (R): %.2f s\n', R);
    
        % Guardar en la base de datos (nota: se debe modificar saveToDatabase.m para incluir ADSR)
        saveToDatabase(instrumentName, fundamentalFreq, harmonics, harmonicIntensities, [A, D, S, R]);
    
        % Graficar los resultados al final
        plotResults(freq, fftMagnitude, harmonicIntensities, harmonics, audioSource, [A, D, S, R]);

    elseif mode == 1
        % Modo Reconocer: Comparar con la base de datos
        % Obtener la fuente de audio
        [audioData, fs, audioSource, ~] = getAudioSource();

        % Procesar el audio para obtener resultados
        [~, ~, ~, harmonicIntensities, ~] = processAudio(audioData, fs);
        [A, D, S, R] = extractADSR(audioData, fs);
        currentEnvelope = [A, D, S, R];

        % Reconocer instrumento
        recognizedInstrument = recognizeInstrument(harmonicIntensities, currentEnvelope, base_datos);
        % if ~isempty(recognizedInstrument)
        %     fprintf('El instrumento reconocido es: %s\n', recognizedInstrument);
        % else
        %     disp('No se pudo reconocer el instrumento.');
        % end
        fig = uifigure(); % Crear una figura UI
        if ~isempty(recognizedInstrument)
            uialert(fig, sprintf('El instrumento reconocido es: %s', recognizedInstrument), ...
        'Instrumento Reconocido', 'Icon', 'success');
        else
            uialert(fig, 'No se pudo reconocer el instrumento.', 'Error', 'Icon', 'error');
        end

    elseif mode == 2
        % Modo Sintetizar: Crear y guardar un nuevo instrumento
        synthesizeInstrument();

    else
        disp('Modo no reconocido.');
    end
end