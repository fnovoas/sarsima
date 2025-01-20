function generateSound(fundamentalFreq, harmonics, harmonicIntensities)
    fs = 44100; % Frecuencia de muestreo
    duration = 3; % Duración del sonido en segundos
    t = 0:1/fs:duration; % Vector de tiempo

    % Generar la señal como suma de senos escalados
    signal = zeros(size(t));
    for i = 1:length(harmonics)
        amplitude = harmonicIntensities(i) / 100; % Escalar intensidad
        signal = signal + amplitude * sin(2 * pi * harmonics(i) * t);
    end

    % Normalizar la señal
    signal = signal / max(abs(signal));

    % Reproducir el sonido
    sound(signal, fs);
end
