function plotResults(freq, fftMagnitude, harmonicIntensities, harmonics, audioSource, envelope)
    % plotResults: Genera gráficos para visualizar el análisis de audio
    %
    % Parámetros:
    % - freq: Vector de frecuencias correspondientes a la FFT
    % - fftMagnitude: Magnitudes absolutas del espectro de Fourier
    % - harmonicIntensities: Intensidades normalizadas de los armónicos
    % - harmonics: Frecuencias de los armónicos identificados
    % - audioSource: Descripción de la fuente de audio (archivo o grabación)
    % - envelope: Vector [A, D, S, R] con los parámetros de la envolvente
    
    if isempty(audioSource)
        audioSource = 'Fuente desconocida';
    end
    
    % Crear la figura con un título general
    fig = figure;
    sgtitle(['Fuente de audio: ', audioSource]);

    % Espectro completo (magnitudes absolutas)
    ax1 = subplot(4, 1, 1);
    plot(freq, fftMagnitude, 'b');
    xlim([20, 20000]);
    xlabel('Frecuencia (Hz)');
    ylabel('Magnitud');
    title('Espectro de frecuencia (magnitudes absolutas)');
    grid on;

    % Intensidades relativas
    ax2 = subplot(4, 1, 2);
    plot(freq, (fftMagnitude / max(fftMagnitude)) * 100, 'r');
    xlim([20, 20000]);
    xlabel('Frecuencia (Hz)');
    ylabel('Intensidad (%)');
    title('Espectro de frecuencia (intensidades relativas)');
    grid on;

    % Armónicos identificados
    ax3 = subplot(4, 1, 3);
    bar(harmonics, harmonicIntensities, 'FaceColor', [0.2 0.6 0.8], 'BarWidth', 0.2);
    xlabel('Frecuencia armónica (Hz)');
    ylabel('Intensidad (%)');
    title('Intensidades de los armónicos');
    grid on;

    % Gráfica de la envolvente ADSR
    ax4 = subplot(4, 1, 4);
    bar([1, 2, 3, 4], envelope, 'FaceColor', [0.8 0.4 0.4], 'BarWidth', 0.5);
    set(ax4, 'XTick', [1 2 3 4], 'XTickLabel', {'A', 'D', 'S', 'R'});
    xlabel('Componentes de la envolvente');
    ylabel('Valor');
    title('Parámetros de la Envolvente ADSR');
    grid on;

    % Estado inicial: escala lineal para las gráficas de espectro
    isLogScale = false;

    % Agregar botón para alternar la escala del eje y (aplica a ax1 y ax2)
    uicontrol('Style', 'pushbutton', 'String', 'Alternar escala Y', ...
              'Position', [20, 20, 120, 30], ...
              'Callback', @toggleScale);

    % Función de callback para alternar la escala de los ejes
    function toggleScale(~, ~)
        isLogScale = ~isLogScale; % Alternar estado
        
        if isLogScale
            set(ax1, 'YScale', 'log');
            set(ax2, 'YScale', 'log');
        else
            set(ax1, 'YScale', 'linear');
            set(ax2, 'YScale', 'linear');
        end
    end
end