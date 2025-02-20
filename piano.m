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
fig.KeyReleaseFcn = @(src, event) detener_piano(src, event, sonidos_activos, notas_activas, mapa_teclas, ax, posiciones_teclas);

% Función para generar tonos
function tono = generar_nota_sintetizada(frecuencia, duracion, fs)
    global instrumento_sintetizado;
    % Si no se ha sintetizado un instrumento, usar tono puro
    if isempty(instrumento_sintetizado)
        t = linspace(0, duracion, round(fs * duracion));
        tono = sin(2 * pi * frecuencia * t);
    else
        t = linspace(0, duracion, round(fs * duracion));
        tono = zeros(size(t));
        % Usar la misma cantidad de armónicos que se definieron (por ejemplo, 16)
        numArm = length(instrumento_sintetizado.harmonicIntensities);
        for k = 1:numArm
            % Cada armónico se escala según la intensidad almacenada.
            % Se calcula el armónico relativo para la nota actual: k * frecuencia.
            amplitude = instrumento_sintetizado.harmonicIntensities(k) / 100;
            tono = tono + amplitude * sin(2 * pi * (frecuencia * k) * t);
        end
        % Normalizar la señal
        tono = tono / max(abs(tono));
    end
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
function detener_piano(~, event, sonidos_activos, notas_activas, mapa_teclas, ax, posiciones_teclas)
    tecla = event.Key; % Capturar tecla liberada
    
    if isKey(sonidos_activos, tecla)
        % Detener sonido
        stop(sonidos_activos(tecla));
        remove(sonidos_activos, tecla);
        
        % Eliminar nota activa
        nota = mapa_teclas(tecla);
        notas_activas(strcmp(notas_activas, nota)) = [];
    end
    
    % Mostrar todas las notas activas en consola
    disp('Notas activas:');
    if isempty(notas_activas)
        disp('Ninguna');
    else
        disp(strjoin(notas_activas, ', '));
    end
    
    % Actualizar piano visual con todas las notas activas
    dibujar_piano(ax, posiciones_teclas, notas_activas);
end

disp('Notas activas:');
disp(notas_activas);