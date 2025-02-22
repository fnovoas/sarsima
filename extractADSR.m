function [A, D, S, R] = extractADSR(audioData, fs)
    % extractADSR: Estima los parámetros de la envolvente ADSR a partir de una señal de audio.
    %
    % Entradas:
    %   audioData - vector de la señal de audio
    %   fs        - frecuencia de muestreo
    %
    % Salidas:
    %   A - Tiempo de ataque (segundos)
    %   D - Tiempo de decaimiento (segundos)
    %   S - Nivel de sostenimiento (valor normalizado entre 0 y 1)
    %   R - Tiempo de liberación (segundos)
    
    % Calcular la envolvente aproximada usando la transformada de Hilbert
    env = abs(hilbert(audioData));
    
    % Suavizar la envolvente (ventana de media móvil)
    windowSize = round(fs/100);  % ajustable según resolución deseada
    envSmooth = smoothdata(env, 'movmean', windowSize);
    
    % Normalizar la envolvente
    envSmooth = envSmooth / max(envSmooth);
    t = (0:length(envSmooth)-1) / fs;
    
    % Estimar Ataque: tiempo hasta alcanzar el 90% de la amplitud máxima
    attackThreshold = 0.9;
    idxAttack = find(envSmooth >= attackThreshold, 1, 'first');
    if isempty(idxAttack)
        A = 0.1;  % valor por defecto en caso de no detectar
    else
        A = t(idxAttack);
    end
    
    % Estimar Decaimiento: tiempo desde el final del ataque hasta alcanzar un nivel
    % aproximado de sostenimiento (por ejemplo, 70% de la amplitud máxima)
    decayThreshold = 0.7;
    idxDecay = find(envSmooth(idxAttack:end) <= decayThreshold, 1, 'first');
    if isempty(idxDecay)
        D = 0.2;  % valor por defecto
    else
        D = t(idxAttack + idxDecay - 1) - t(idxAttack);
    end
    
    % Estimar Sostenimiento: se toma como el valor medio en la parte central de la nota
    sustainWindow = floor(length(envSmooth)*0.5) : floor(length(envSmooth)*0.8);
    S = mean(envSmooth(sustainWindow));
    
    % Liberación: en señales grabadas puede no estar definido claramente.
    % Se asigna un valor por defecto o se podría intentar estimarlo si la nota decrece.
    R = 0.5;  % valor por defecto (ajustable)
end
