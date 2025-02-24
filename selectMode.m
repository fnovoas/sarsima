% function mode = selectMode()
%     disp('Seleccione un modo:');
%     disp('0: Modo grabar (guardar en base de datos).');
%     disp('1: Modo reconocer (identificar instrumento).');
%     disp('2: Modo sintetizar (crear y guardar un nuevo instrumento).');
%     mode = input('Ingrese su opción (0, 1 o 2): ');
%     while ~ismember(mode, [0, 1, 2])
%         disp('Opción no válida. Por favor, ingrese 0, 1 o 2.');
%         mode = input('Ingrese su opción (0, 1 o 2): ');
%     end
% end

function mode = selectMode()
    % Crear una figura para la interfaz gráfica
    fig = uifigure('Name', 'Selección de Modo', 'Position', [100 100 300 200]);
    
    % Crear botones para cada modo
    btnGrabar = uibutton(fig, 'push', ...
        'Text', 'Modo Grabar (0)', ...
        'Position', [50 120 200 30], ...
        'ButtonPushedFcn', @(btn,event) setMode(0));
    
    btnReconocer = uibutton(fig, 'push', ...
        'Text', 'Modo Reconocer (1)', ...
        'Position', [50 80 200 30], ...
        'ButtonPushedFcn', @(btn,event) setMode(1));
    
    btnSintetizar = uibutton(fig, 'push', ...
        'Text', 'Modo Sintetizar (2)', ...
        'Position', [50 40 200 30], ...
        'ButtonPushedFcn', @(btn,event) setMode(2));
    
    % Variable para almacenar la selección del modo
    mode = -1;  % Valor inicial inválido
    
    % Esperar a que el usuario seleccione un modo
    waitfor(fig, 'UserData');
    
    % Obtener el modo seleccionado antes de cerrar la figura
    mode = fig.UserData;
    
    % Cerrar la figura después de obtener el valor
    close(fig);
    
    % Función para establecer el modo seleccionado
    function setMode(selectedMode)
        fig.UserData = selectedMode;  % Almacenar el modo seleccionado
        uiresume(fig);               % Reanudar la ejecución
    end
end