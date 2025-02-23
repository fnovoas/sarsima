function sintetizarInstrumento()
    global base_datos;
    global instrumento_sintetizado;

    % Crear la figura principal
    fig = uifigure('Name', 'Síntesis de Instrumento', 'Position', [100, 100, 400, 700]);

    % Cuadro de texto para el nombre del instrumento
    uilabel(fig, 'Text', 'Nombre del Instrumento:', 'Position', [50, 650, 150, 20]);
    nombreField = uieditfield(fig, 'text', 'Position', [200, 650, 150, 22]);

    % Campos para ADSR
    uilabel(fig, 'Text', 'Ataque (A) [s]:', 'Position', [50, 610, 150, 20]);
    ataqueField = uieditfield(fig, 'numeric', 'Position', [200, 610, 100, 22]);

    uilabel(fig, 'Text', 'Decaimiento (D) [s]:', 'Position', [50, 580, 150, 20]);
    decaimientoField = uieditfield(fig, 'numeric', 'Position', [200, 580, 100, 22]);

    uilabel(fig, 'Text', 'Sostenimiento (S) [0-1]:', 'Position', [50, 550, 150, 20]);
    sostenimientoField = uieditfield(fig, 'numeric', 'Position', [200, 550, 100, 22]);

    uilabel(fig, 'Text', 'Liberación (R) [s]:', 'Position', [50, 520, 150, 20]);
    liberacionField = uieditfield(fig, 'numeric', 'Position', [200, 520, 100, 22]);

    % Título para los armónicos
    uilabel(fig, 'Text', 'Intensidades de Armónicos (%)', 'FontWeight', 'bold', 'Position', [50, 490, 300, 20]);

    % Campos para los armónicos (uno debajo del otro)
    armonicosFields = gobjects(1, 16); % Inicializar como arreglo de objetos gráficos
    startY = 460; % Posición inicial en Y
    spacingY = 30; % Espaciado vertical entre campos

    for i = 1:16
        % Etiqueta para identificar cada armónico
        uilabel(fig, 'Text', sprintf('Armónico %d:', i), 'Position', [50, startY - (i-1) * spacingY, 80, 22]);

        % Campo de entrada para cada armónico
        armonicosFields(i) = uieditfield(fig, 'numeric', 'Position', [150, startY - (i-1) * spacingY, 100, 22]);

        % Asignar valor por defecto (1%)
        armonicosFields(i).Value = 1;
    end

    % Botón para guardar
    btnGuardar = uibutton(fig, 'Text', 'Guardar Instrumento', 'Position', [300, 5, 120, 30], ...
        'ButtonPushedFcn', @(btn, event) guardarInstrumento());

    % Función para guardar el instrumento
    function guardarInstrumento()
        fundamentalFreq = 440;
        harmonicIntensities = ones(1, 16);
    
        for i = 1:16
            harmonicIntensities(i) = armonicosFields(i).Value;
        end
    
        A = ataqueField.Value;
        D = decaimientoField.Value;
        S = sostenimientoField.Value;
        R = liberacionField.Value;
        instrumentName = nombreField.Value;
    
        saveToDatabase(instrumentName, fundamentalFreq, fundamentalFreq * (1:16), harmonicIntensities, [A, D, S, R]);
    
        instrumento_sintetizado.fundamentalFreq = fundamentalFreq;
        instrumento_sintetizado.harmonicIntensities = harmonicIntensities;
        instrumento_sintetizado.envelope = [A, D, S, R];
    
        close(fig);
        uialert(uifigure, 'Instrumento guardado y sintetizado.', 'Éxito');
    
        % Ejecutar piano() en el workspace base
        evalin('base', 'piano();');
    end


end