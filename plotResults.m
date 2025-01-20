function plotResults(freq, fftMagnitude, harmonicIntensities, harmonics, audioSource)
    % plotResults: Genera gráficos para visualizar el análisis de audio
    %
    % Parámetros:
    % - freq: Vector de frecuencias correspondientes a la FFT
    % - fftMagnitude: Magnitudes absolutas del espectro de Fourier
    % - harmonicIntensities: Intensidades normalizadas de los armónicos
    % - harmonics: Frecuencias de los armónicos identificados
    % - audioSource: Descripción de la fuente de audio (archivo o grabación)

    % Crear figura con subtítulos
    if isempty(audioSource)
        audioSource = 'Fuente desconocida';
    end
    
    % Crear la figura
    fig = figure;
    sgtitle(['Fuente de audio: ', audioSource]);

    % Espectro completo (magnitudes absolutas)
    ax1 = subplot(3, 1, 1);
    plot1 = plot(freq, fftMagnitude, 'b');
    xlim([20, 20000]);
    xlabel('Frecuencia (Hz)');
    ylabel('Magnitud');
    title('Espectro de frecuencia (magnitudes absolutas)');
    grid on;

    % Intensidades relativas
    ax2 = subplot(3, 1, 2);
    plot2 = plot(freq, (fftMagnitude / max(fftMagnitude)) * 100, 'r');
    xlim([20, 20000]);
    xlabel('Frecuencia (Hz)');
    ylabel('Intensidad (%)');
    title('Espectro de frecuencia (intensidades relativas)');
    grid on;

    % Armónicos identificados
    ax3 = subplot(3, 1, 3);
    barPlot = bar(harmonics, harmonicIntensities, 'FaceColor', [0.2 0.6 0.8], 'BarWidth', 0.2);
    xlabel('Frecuencia armónica (Hz)');
    ylabel('Intensidad (%)');
    title('Intensidades de los armónicos');
    grid on;

    % Estado inicial: escala lineal
    isLogScale = false;

    % Agregar botón para alternar la escala del eje y
    uicontrol('Style', 'pushbutton', 'String', 'Alternar escala Y', ...
              'Position', [20, 20, 120, 30], ...
              'Callback', @toggleScale);

    % Función de callback para alternar la escala
    function toggleScale(~, ~)
        isLogScale = ~isLogScale; % Alternar estado
        
        if isLogScale
            % Cambiar a escala logarítmica
            set(ax1, 'YScale', 'log');
            set(ax2, 'YScale', 'log');
        else
            % Cambiar a escala lineal
            set(ax1, 'YScale', 'linear');
            set(ax2, 'YScale', 'linear');
        end
    end
end
