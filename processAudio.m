function [freq, fftMagnitude, fundamentalFreq, harmonicIntensities, harmonics] = processAudio(audioData, fs)
    % Eliminar offset DC y normalizar
    audioData = audioData - mean(audioData);
    audioData = audioData / max(abs(audioData));

    % Realizar la Transformada de Fourier
    N = length(audioData);
    fftResult = fft(audioData);
    fftMagnitude = abs(fftResult(1:N/2+1));
    freq = (0:N/2) * (fs / N);

    % Normalizar intensidades para todo el espectro
    fftMagnitudeNormalized = (fftMagnitude / max(fftMagnitude)) * 100;

    % Encontrar la frecuencia fundamental
    [~, idx] = max(fftMagnitude);
    fundamentalFreq = freq(idx);

    % Identificar armónicos y sus intensidades
    harmonics = fundamentalFreq * (1:16);
    harmonicIntensities = zeros(size(harmonics));

    for i = 1:length(harmonics)
        [~, closestIdx] = min(abs(freq - harmonics(i)));
        harmonicIntensities(i) = fftMagnitude(closestIdx);
    end

    % Normalizar intensidades a porcentaje
    harmonicIntensities = (harmonicIntensities / max(harmonicIntensities)) * 100;
    harmonicIntensities = arrayfun(@(x) str2double(sprintf('%.10f', x)), harmonicIntensities);
end