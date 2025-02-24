function [audioData, fs, audioSource, instrumentName] = getAudioSource()
    % % Seleccionar fuente de audio
    % disp('Seleccione una fuente de audio:');
    % disp('0: Cargar un archivo de audio existente.');
    % disp('1: Grabar audio con el micrófono.');
    % option = input('Ingrese su opción (1 o 0): ');

    % 
    % while option ~= 1 && option ~= 0
    %     disp('Opción no válida. Por favor, ingrese 1 o 0.');
    %     option = input('Ingrese su opción (1 o 0): ');
    % end

    option = selectAudioSourceGUI();

    fs = 44100; % Frecuencia de muestreo
    duration = 3; % Duración en segundos

    if option == 1
        % % Grabar audio desde el micrófono
        % disp('Grabando audio desde el micrófono...');
        % recorder = audiorecorder(fs, 16, 1);
        % recordblocking(recorder, duration);
        % audioData = getaudiodata(recorder);
        % 
        % % Verificar duración
        % if length(audioData) < fs * 2
        %     disp('El audio grabado debe durar al menos 2 segundos. Intente nuevamente.');
        %     audioData = [];
        %     audioSource = '';
        %     instrumentName = '';
        %     return;
        % elseif length(audioData) < fs * duration
        %     % Rellenar con silencio si dura entre 2 y 3 segundos
        %     disp('El audio tiene menos de 3 segundos. Rellenando con silencio...');
        %     audioData = [audioData; zeros(fs * duration - length(audioData), 1)];
        % end
        % 
        % % Asegurarse de usar solo los primeros 3 segundos
        % audioData = audioData(1:fs * duration);
        % disp('Grabación completa.');
        % audioSource = 'Nota grabada';
        % instrumentName = input('Ingrese el nombre del instrumento correspondiente a la grabación: ', 's');
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        [audioData, fs, audioSource, instrumentName] = grabarAudioConGUI(fs, duration); %el problema es que no estoy usando los valores que retorna esto creo, la funcion grande getAudioSource no esta devola
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    else
        % Cargar archivo de audio
        [fileName, pathName] = uigetfile({'*.wav;*.mp3', 'Archivos de audio (*.wav, *.mp3)'});
        if isequal(fileName, 0)
            disp('No se seleccionó ningún archivo. Saliendo del programa.');
            audioData = [];
            audioSource = '';
            instrumentName = '';
            return;
        end

        audioFile = fullfile(pathName, fileName);
        [audioData, fs] = audioread(audioFile);
        audioData = mean(audioData, 2); % Convertir a mono si es estéreo

        % Verificar duración
        if length(audioData) < fs * 2
            disp('El audio cargado debe durar al menos 2 segundos. Intente nuevamente.');
            audioData = [];
            audioSource = '';
            instrumentName = '';
            return;
        elseif length(audioData) < fs * duration
            % Rellenar con silencio si dura entre 2 y 3 segundos
            disp('El audio tiene menos de 3 segundos. Rellenando con silencio...');
            audioData = [audioData; zeros(fs * duration - length(audioData), 1)];
        end

        % Usar solo los primeros 3 segundos
        audioData = audioData(1:fs * duration);
        disp(['Archivo ', fileName, ' cargado correctamente.']);
        audioSource = fileName;
        [~, instrumentName, ~] = fileparts(fileName); % Obtener nombre del instrumento
    end
end


function option = selectAudioSourceGUI()
    % Crear una figura para la interfaz gráfica
    fig = uifigure('Name', 'Selección de Fuente de Audio', 'Position', [100 100 300 150]);
    
    % Crear botones para cada opción
    btnCargarArchivo = uibutton(fig, 'push', ...
        'Text', 'Cargar archivo de audio (0)', ...
        'Position', [50 80 200 30], ...
        'ButtonPushedFcn', @(btn,event) setOption(0));
    
    btnGrabarAudio = uibutton(fig, 'push', ...
        'Text', 'Grabar audio con micrófono (1)', ...
        'Position', [50 40 200 30], ...
        'ButtonPushedFcn', @(btn,event) setOption(1));
    
    % Variable para almacenar la selección de la opción
    option = -1;  % Valor inicial inválido
    
    % Esperar a que el usuario seleccione una opción
    waitfor(fig, 'UserData');
    
    % Obtener la opción seleccionada antes de cerrar la figura
    option = fig.UserData;
    
    % Cerrar la figura después de obtener el valor
    close(fig);
    
    % Función para establecer la opción seleccionada
    function setOption(selectedOption)
        fig.UserData = selectedOption;  % Almacenar la opción seleccionada
        uiresume(fig);                 % Reanudar la ejecución
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [audioData, fs, audioSource, instrumentName] = grabarAudioConGUI(fs, duration)
    % Crear una figura para la interfaz gráfica
    fig = uifigure('Name', 'Grabación de Audio', 'Position', [100 100 400 250]);
    
    % Crear un label para mostrar mensajes
    lblMensaje = uilabel(fig, ...
        'Text', 'Presione "Grabar" para comenzar.', ...
        'Position', [50 180 300 30], ...
        'FontSize', 12, ...
        'HorizontalAlignment', 'center');
    
    % Crear un botón para iniciar la grabación
    btnGrabar = uibutton(fig, 'push', ...
        'Text', 'Grabar', ...
        'Position', [150 140 100 30], ...
        'ButtonPushedFcn', @(btn, event) grabarAudio());
    
    % Variables para almacenar los resultados
    audioData = [];
    audioSource = '';
    instrumentName = '';
    
    % Esperar a que el usuario interactúe con la interfaz
    uiwait(fig);
    
    % Función para grabar audio
    function grabarAudio()
        % Actualizar el mensaje en la interfaz
        lblMensaje.Text = 'Grabando audio desde el micrófono...';
        
        % Grabar audio
        recorder = audiorecorder(fs, 16, 1);
        recordblocking(recorder, duration);
        audioData = getaudiodata(recorder);
        
        % Verificar duración
        if length(audioData) < fs * 2
            lblMensaje.Text = 'El audio grabado debe durar al menos 2 segundos. Intente nuevamente.';
            audioData = [];
            audioSource = '';
            instrumentName = '';
            return;
        elseif length(audioData) < fs * duration
            % Rellenar con silencio si dura entre 2 y 3 segundos
            lblMensaje.Text = 'El audio tiene menos de 3 segundos. Rellenando con silencio...';
            audioData = [audioData; zeros(fs * duration - length(audioData), 1)];
        end
        
        % Asegurarse de usar solo los primeros 3 segundos
        audioData = audioData(1:fs * duration);
        lblMensaje.Text = 'Grabación completa. Ingrese el nombre del instrumento y presione "Confirmar".';
        
        % Crear un campo de texto para ingresar el nombre del instrumento
        lblInstrumento = uilabel(fig, ...
            'Text', 'Nombre del instrumento:', ...
            'Position', [50 100 150 22], ...
            'FontSize', 12);
        
        editInstrumento = uieditfield(fig, 'text', ...
            'Position', [200 100 150 22], ...
            'Editable', 'on');
        
        % Crear un botón para confirmar el nombre del instrumento
        btnConfirmar = uibutton(fig, 'push', ...
            'Text', 'Confirmar', ...
            'Position', [150 60 100 30], ...
            'ButtonPushedFcn', @(btn, event) confirmarNombre(editInstrumento.Value));
    end
    
    % Función para confirmar el nombre del instrumento
    function confirmarNombre(instrumentNameValue)
        if isempty(instrumentNameValue)
            lblMensaje.Text = 'No se ingresó un nombre de instrumento. Intente nuevamente.';
            return;
        end
        
        % Almacenar el nombre del instrumento
        instrumentName = instrumentNameValue;
        
        % Actualizar el mensaje final
        lblMensaje.Text = 'Grabación finalizada. Puede cerrar la ventana.';
        audioSource = 'Nota grabada';
        
        % Cerrar la interfaz gráfica
        uiresume(fig);
        close(fig);
    end
end