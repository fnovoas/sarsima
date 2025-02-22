% Frecuencias de las notas musicales
notas = struct( ...
    'DO3', 261.626, 'DOS3', 277.183, ...
    'RE3', 293.665, 'RES3', 311.127, ...
    'MI3', 329.628, 'FA3', 349.228, ...
    'FAS3', 369.994, 'SOL3', 391.995, ...
    'SOLS3', 415.305, 'LA3', 440, ...
    'LAS3', 466.164, 'SI3', 493.883, ...
    'DO4', 523.251, 'DOS4', 554.365, ...
    'RE4', 587.330, 'RES4', 622.254, ...
    'MI4', 659.255);

% Mapeo de teclas a notas y posiciones en el piano
mapa_teclas = containers.Map( ...
    {'a', 'w', 's', 'e', 'd', 'f', 't', 'g', 'y', 'h', 'u', 'j', 'k', 'o', 'l', 'p', '0'}, ...
    {'DO3', 'DOS3', 'RE3', 'RES3', 'MI3', 'FA3', 'FAS3', 'SOL3', 'SOLS3', 'LA3', 'LAS3', 'SI3', 'DO4', 'DOS4', 'RE4', 'RES4', 'MI4'});
posiciones_teclas = containers.Map( ...
    {'DO3', 'DOS3', 'RE3', 'RES3', 'MI3', 'FA3', 'FAS3', 'SOL3', 'SOLS3', 'LA3', 'LAS3', 'SI3', 'DO4', 'DOS4', 'RE4', 'RES4', 'MI4'}, ...
    [0, 0.5, 1, 1.5, 2, 3, 3.5, 4, 4.5, 5, 5.5, 6, 7, 7.5, 8, 8.5, 9]);

% Frecuencia de muestreo
fs = 8000;

% Crear ventana para el piano visual
fig = uifigure('Name', 'Piano Virtual', 'Position', [100 100 800 300]);
ax = uiaxes(fig, 'Position', [50 50 700 200]);

% Dibujar el piano inicial
dibujar_piano(ax, posiciones_teclas, []);

% Contenedor para objetos audioplayer activos y notas activas
sonidos_activos = containers.Map();
notas_activas = {};

% Asignar los callbacks
fig.KeyPressFcn = @(src, event) tocar_piano(src, event, mapa_teclas, notas, fs, sonidos_activos, notas_activas, ax, posiciones_teclas);
fig.KeyReleaseFcn = @(src, event) detener_piano(src, event, sonidos_activos, notas_activas, mapa_teclas, notas, ax, posiciones_teclas);

% Función para generar tonos
function tono = generar_nota_sintetizada(frecuencia, duracion, fs)
    global instrumento_sintetizado;
    t = linspace(0, duracion, round(fs * duracion));
    
    if isempty(instrumento_sintetizado)
        % Si no se ha sintetizado un instrumento, generar una onda senoidal simple
        tono = sin(2 * pi * frecuencia * t);
    else
        % Generar tono a partir de los armónicos del instrumento sintetizado
        tono = zeros(size(t));
        numArm = length(instrumento_sintetizado.harmonicIntensities);
        for k = 1:numArm
            amplitude = instrumento_sintetizado.harmonicIntensities(k) / 100;
            tono = tono + amplitude * sin(2 * pi * (frecuencia * k) * t);
        end
    end
    
    % --- Aplicar la envolvente ADSR ---
    % Si el instrumento sintetizado tiene parámetros ADSR, usarlos; de lo contrario, se usan valores por defecto.
    if ~isempty(instrumento_sintetizado) && isfield(instrumento_sintetizado, 'envelope')
        ADSR = instrumento_sintetizado.envelope;  % Se espera un vector [A, D, S, R]
        A = ADSR(1);
        D = ADSR(2);
        S = ADSR(3);
        R = ADSR(4);
    else
        % Valores por defecto
        A = 0.1;  % Ataque
        D = 0.2;  % Decaimiento
        S = 0.7;  % Sostenimiento
        R = 0.5;  % Liberación
    end
    
    envelope = createADSR(A, D, S, R, duracion, fs);
    tono = tono .* envelope;
    % ----------------------------------
    
    % Normalizar la señal
    tono = tono / max(abs(tono));
end

function dibujar_piano(ax, posiciones, notas_activas)
    cla(ax);
    hold(ax, 'on');

    % Dibujar teclas blancas
    teclas_blancas = {'DO3', 'RE3', 'MI3', 'FA3', 'SOL3', 'LA3', 'SI3', 'DO4', 'RE4', 'MI4'};
    for i = 1:length(teclas_blancas)
        x = posiciones(teclas_blancas{i});
        color = 'w';
        if any(strcmp(notas_activas, teclas_blancas{i}))
            color = 'g'; % Cambiar color si está activa
        end
        rectangle(ax, 'Position', [x, 0, 1, 3], 'FaceColor', color, 'EdgeColor', 'k');
    end
    
    % Dibujar teclas negras
    teclas_negras = {'DOS3', 'RES3', 'FAS3', 'SOLS3', 'LAS3', 'DOS4', 'RES4'};
    for i = 1:length(teclas_negras)
        x = posiciones(teclas_negras{i}) + 0.3; % Ajustar posición al centro de las teclas blancas
        color = 'k';
        if any(strcmp(notas_activas, teclas_negras{i}))
            color = 'g'; % Cambiar color si está activa
        end
        rectangle(ax, 'Position', [x, 1.5, 0.6, 1.5], 'FaceColor', color, 'EdgeColor', 'k');
    end
    hold(ax, 'off');
    ax.XLim = [0, 10]; % Asegurar límites para la visualización correcta
    ax.YLim = [0, 3];
    ax.XTick = [];
    ax.YTick = [];
    drawnow; % Forzar actualización gráfica
end

% Función para tocar el piano
function tocar_piano(~, event, mapa_teclas, notas, fs, sonidos_activos, notas_activas, ax, posiciones_teclas)
    tecla = event.Key; % Capturar tecla presionada
    
    if isKey(mapa_teclas, tecla) && ~isKey(sonidos_activos, tecla)
        nota = mapa_teclas(tecla);
        frecuencia = notas.(nota);
        duracion = 5; % Tiempo máximo para el tono
        
        % Generar tono usando la función actualizada
        tono = generar_nota_sintetizada(frecuencia, duracion, fs);

        player = audioplayer(tono, fs);
        player.UserData = tono;  % Guardar la señal completa para usarla en el release

        % Iniciar sonido y almacenar el objeto
        play(player);
        sonidos_activos(tecla) = player;
        
        % Agregar nota activa sin duplicados
        if ~any(strcmp(notas_activas, nota))
            notas_activas{end + 1} = nota;
        end
    end
    
    % Mostrar todas las notas activas en consola
    disp('Notas activas:');
    disp(strjoin(notas_activas, ', '));
    
    % Actualizar piano visual con todas las notas activas
    dibujar_piano(ax, posiciones_teclas, notas_activas);
end

% Función para detener el sonido del piano
function detener_piano(~, event, sonidos_activos, notas_activas, mapa_teclas, notas, ax, posiciones_teclas)
    tecla = event.Key; % Capturar tecla liberada
    
    if isKey(sonidos_activos, tecla)
        % Obtener el audioplayer actual
        player = sonidos_activos(tecla);
        % Obtener la posición actual en muestras
        currentSample = get(player, 'CurrentSample');
        % Detener el audioplayer original
        stop(player);
        remove(sonidos_activos, tecla);
        
        % Extraer la señal original reproducida (almacenada en UserData)
        originalSignal = get(player, 'UserData');
        fs = player.SampleRate;
        
        % Acceder a los parámetros de release del instrumento
        global instrumento_sintetizado;
        if ~isempty(instrumento_sintetizado) && isfield(instrumento_sintetizado, 'envelope')
            envParams = instrumento_sintetizado.envelope;  % [A, D, S, R]
            R = envParams(4);
        else
            R = 0.5;  % Valor por defecto
        end
        
        % Calcular el número de muestras para la fase de liberación
        numReleaseSamples = round(R * fs);
        
        % Extraer la porción restante de la señal
        remainingSignal = originalSignal(currentSample:end);
        % Si la señal restante es más larga que numReleaseSamples, usar solo esa parte
        if length(remainingSignal) > numReleaseSamples
            remainingSignal = remainingSignal(1:numReleaseSamples);
        else
            numReleaseSamples = length(remainingSignal);
        end
        
        % Crear la envolvente de fade-out (por ejemplo, linealmente de 1 a 0)
        fadeEnvelope = linspace(1, 0, numReleaseSamples)';
        fadeOutSignal = remainingSignal .* fadeEnvelope;
        % (Opcional) Normalizar la señal de release
        if max(abs(fadeOutSignal)) > 0
            fadeOutSignal = fadeOutSignal / max(abs(fadeOutSignal));
        end
        
        % Crear un nuevo audioplayer para reproducir la señal modificada de release
        % (La reproducción se inicia inmediatamente y forma parte de la nota liberada)
        releasePlayer = audioplayer(fadeOutSignal, fs);
        play(releasePlayer);
        
        % Eliminar la nota de la lista de notas activas
        nota = mapa_teclas(tecla);
        notas_activas(strcmp(notas_activas, nota)) = [];
    end
    
    % Actualizar y redibujar el piano
    disp('Notas activas:');
    if isempty(notas_activas)
        disp('Ninguna');
    else
        disp(strjoin(notas_activas, ', '));
    end
    dibujar_piano(ax, posiciones_teclas, notas_activas);
end

disp('Notas activas:');
disp(notas_activas);