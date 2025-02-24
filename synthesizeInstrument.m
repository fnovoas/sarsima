% function synthesizeInstrument()
%     global base_datos;
%     global instrumento_sintetizado;  % Declarar la variable global dentro de la función
% 
%     % Usar la frecuencia fundamental predeterminada de 440 Hz
%     fundamentalFreq = 440;
% 
%     % Solicitar al usuario los porcentajes de intensidad para los 15 armónicos restantes (hasta 10 cifras decimales)
%     harmonicIntensities = zeros(1, 16);
%     harmonicIntensities(1) = 100.0000000000; % Intensidad fija para el primer armónico
%     disp('Ingrese los porcentajes de intensidad para los 15 armónicos restantes (hasta 10 cifras decimales):');
%     for i = 2:16
%         while true
%             value = input(sprintf('Armónico %d: ', i));
%             % Validar entrada
%             if isnumeric(value) && value >= 0 && value <= 100
%                 valueStr = sprintf('%.10f', value); % Formatear a 10 decimales
%                 valueRounded = str2double(valueStr); % Asegurar que tenga exactamente 10 decimales
%                 harmonicIntensities(i) = valueRounded;
%                 break;
%             else
%                 disp('Entrada no válida. Ingrese un número entre 0 y 100 con hasta 10 cifras decimales.');
%             end
%         end
%     end
% 
%     % Solicitar el nombre del nuevo instrumento
%     instrumentName = input('Ingrese el nombre del nuevo instrumento: ', 's');
% 
%     % Crear vector de frecuencias de los armónicos
%     harmonics = fundamentalFreq * (1:16);
% 
%     % Solicitar los parámetros ADSR al usuario:
%     A = input('Ingrese el tiempo de Ataque (A) en segundos: ');
%     D = input('Ingrese el tiempo de Decaimiento (D) en segundos: ');
%     S = input('Ingrese el nivel de Sostenimiento (S) (entre 0 y 1): ');
%     R = input('Ingrese el tiempo de Liberación (R) en segundos: ');
% 
%     % Guardar en la base de datos (junto con los armónicos)
%     saveToDatabase(instrumentName, fundamentalFreq, harmonics, harmonicIntensities, [A, D, S, R]);
% 
%     % Almacenar en la variable global
%     instrumento_sintetizado.fundamentalFreq = fundamentalFreq;
%     instrumento_sintetizado.harmonicIntensities = harmonicIntensities;
%     instrumento_sintetizado.envelope = [A, D, S, R];
% 
%     % Lanzar directamente el piano con el instrumento sintetizado
%     disp('Lanzando el piano con el instrumento sintetizado...');
%     piano;
% end



function synthesizeInstrument()
    global base_datos;
    global instrumento_sintetizado;  % Declarar la variable global dentro de la función

    % Crear una figura para la interfaz gráfica
    fig = uifigure('Name', 'Sintetizar Instrumento', 'Position', [100 100 600 600]);
    
    % Crear un label para el título
    lblTitulo = uilabel(fig, ...
        'Text', 'Sintetizar Nuevo Instrumento', ...
        'Position', [50 550 500 30], ...
        'FontSize', 16, ...
        'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center');
    
    % Crear un panel para los armónicos
    pnlArmonicos = uipanel(fig, ...
        'Title', 'Intensidad de los Armónicos (2-16)', ...
        'Position', [50 300 500 270]);
    
    % Crear campos de texto para los armónicos en dos columnas
    harmonicFields = cell(1, 16); % Arreglo para almacenar los campos de texto
    for i = 2:16
        % Calcular la posición en la columna izquierda o derecha
        if i <= 8
            columna = 20;  % Columna izquierda
            fila = 210 - (i-2)*30;
        else
            columna = 270; % Columna derecha
            fila = 210 - (i-9)*30;
        end
        
        % Crear el label para el armónico
        uilabel(pnlArmonicos, ...
            'Text', sprintf('Armónico %d:', i), ...
            'Position', [columna fila 100 22], ...
            'FontSize', 10);
        
        % Crear el campo de texto para el armónico
        editArmonico = uieditfield(pnlArmonicos, 'numeric', ...
            'Position', [columna + 100 fila 100 22], ...
            'Limits', [0 100], ...
            'RoundFractionalValues', 'on');
        
        % Guardar el campo de texto en el arreglo
        harmonicFields{i} = editArmonico;
    end
    
    % Crear un campo de texto para el nombre del instrumento
    lblNombre = uilabel(fig, ...
        'Text', 'Nombre del instrumento:', ...
        'Position', [50 250 150 22], ...
        'FontSize', 12);
    
    editNombre = uieditfield(fig, 'text', ...
        'Position', [200 250 250 22], ...
        'Editable', 'on');
    
    % Crear un panel para los parámetros ADSR
    pnlADSR = uipanel(fig, ...
        'Title', 'Parámetros ADSR', ...
        'Position', [50 50 500 180]);
    
    % Campos de texto para ADSR
    uilabel(pnlADSR, ...
        'Text', 'Ataque (A) en segundos:', ...
        'Position', [20 130 150 22], ...
        'FontSize', 10);
    
    editAtaque = uieditfield(pnlADSR, 'numeric', ...
        'Position', [180 130 100 22], ...
        'Limits', [0 Inf], ...
        'ValueDisplayFormat', '%.2f');
    
    uilabel(pnlADSR, ...
        'Text', 'Decaimiento (D) en segundos:', ...
        'Position', [20 90 150 22], ...
        'FontSize', 10);
    
    editDecaimiento = uieditfield(pnlADSR, 'numeric', ...
        'Position', [180 90 100 22], ...
        'Limits', [0 Inf], ...
        'ValueDisplayFormat', '%.2f');
    
    uilabel(pnlADSR, ...
        'Text', 'Sostenimiento (S) (0-1):', ...
        'Position', [20 50 150 22], ...
        'FontSize', 10);
    
    editSostenimiento = uieditfield(pnlADSR, 'numeric', ...
        'Position', [180 50 100 22], ...
        'Limits', [0 1], ...
        'ValueDisplayFormat', '%.2f');
    
    uilabel(pnlADSR, ...
        'Text', 'Liberación (R) en segundos:', ...
        'Position', [20 10 150 22], ...
        'FontSize', 10);
    
    editLiberacion = uieditfield(pnlADSR, 'numeric', ...
        'Position', [180 10 100 22], ...
        'Limits', [0 Inf], ...
        'ValueDisplayFormat', '%.2f');
    
    % Crear un botón para confirmar
    btnConfirmar = uibutton(fig, 'push', ...
        'Text', 'Sintetizar', ...
        'Position', [250 10 100 30], ...
        'ButtonPushedFcn', @(btn, event) confirmarDatos());
    
    % Esperar a que el usuario interactúe con la interfaz
    uiwait(fig);
    
    % Función para confirmar los datos
    function confirmarDatos()
        % Obtener los valores de los armónicos
        harmonicIntensities = zeros(1, 16);
        harmonicIntensities(1) = 100.0000000000; % Intensidad fija para el primer armónico
        for i = 2:16
            harmonicIntensities(i) = harmonicFields{i}.Value;
        end
        
        % Obtener el nombre del instrumento
        instrumentName = editNombre.Value;
        
        % Obtener los valores de ADSR
        A = editAtaque.Value;
        D = editDecaimiento.Value;
        S = editSostenimiento.Value;
        R = editLiberacion.Value;
        
        % Validar que todos los campos estén completos
        if isempty(instrumentName) || any(isnan(harmonicIntensities(2:16))) || ...
           isnan(A) || isnan(D) || isnan(S) || isnan(R)
            uialert(fig, 'Por favor, complete todos los campos correctamente.', 'Error', 'Icon', 'error');
            return;
        end
        
        % Crear vector de frecuencias de los armónicos
        fundamentalFreq = 440; % Frecuencia fundamental predeterminada
        harmonics = fundamentalFreq * (1:16);
        
        % Guardar en la base de datos (junto con los armónicos)
        saveToDatabase(instrumentName, fundamentalFreq, harmonics, harmonicIntensities, [A, D, S, R]);
        
        % Almacenar en la variable global
        instrumento_sintetizado.fundamentalFreq = fundamentalFreq;
        instrumento_sintetizado.harmonicIntensities = harmonicIntensities;
        instrumento_sintetizado.envelope = [A, D, S, R];
        
        % Cerrar la interfaz gráfica
        uiresume(fig);
        close(fig);
        
        % Lanzar directamente el piano con el instrumento sintetizado
        disp('Lanzando el piano con el instrumento sintetizado...');
        evalin('base', 'piano;');  % Ejecutar piano en el espacio de trabajo base
    end
end