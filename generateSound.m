function generateSound(fundamentalFreq, harmonics, harmonicIntensities)
    fs = 44100; % Frecuencia de muestreo
    % Usar una duración larga para permitir el sostenimiento
    durationOn = 30; % Por ejemplo, 30 segundos de fase "on"
    t = 0:1/fs:durationOn;
    
    % Generar la señal como suma de senos escalados por sus intensidades
    signal = zeros(size(t));
    for i = 1:length(harmonics)
        amplitude = harmonicIntensities(i) / 100; % Escalar intensidad
        signal = signal + amplitude * sin(2 * pi * harmonics(i) * t);
    end

    % --- Integrar la envolvente ADSR para la fase "on" ---
    % Se asume que los parámetros ADSR del instrumento se encuentran en la variable global 'instrumento_sintetizado'
    global instrumento_sintetizado;
    if isfield(instrumento_sintetizado, 'envelope')
        ADSR = instrumento_sintetizado.envelope;  % Vector [A, D, S, R]
        A = ADSR(1);
        D = ADSR(2);
        S = ADSR(3);
        % Durante la fase "on" se omite la liberación, es decir, R = 0
        R = 0;
    else
        % Valores por defecto en caso de no tener parámetros específicos
        A = 0.1;  
        D = 0.2;  
        S = 0.7;  
        R = 0;
    end
    
    % Crear y aplicar la envolvente sin fase de liberación para la fase "on"
    envelope = createADSR(A, D, S, R, durationOn, fs);
    signal = signal .* envelope;
    % ---------------------------------

    % Normalizar la señal
    signal = signal / max(abs(signal));

    % Reproducir la señal. Mientras la tecla esté oprimida, se reproducirá la parte "on"
    sound(signal, fs);
end
