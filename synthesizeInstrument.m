function synthesizeInstrument()
    global base_datos;

    % Frecuencia fundamental fija por defecto
    defaultFreq = 440;

    % Solicitar al usuario la frecuencia deseada inicial
    userFreq = input('Ingrese la frecuencia deseada para el sonido (presione Enter para usar 440 Hz): ', 's');
    if isempty(userFreq)
        fundamentalFreq = defaultFreq;
    else
        fundamentalFreq = str2double(userFreq);
        if isnan(fundamentalFreq) || fundamentalFreq <= 0
            disp('Entrada no válida. Se utilizará la frecuencia predeterminada de 440 Hz.');
            fundamentalFreq = defaultFreq;
        end
    end

    % Solicitar al usuario los porcentajes de los armónicos
    harmonicIntensities = zeros(1, 16);
    harmonicIntensities(1) = 100.0000000000; % Intensidad fija para el primer armónico
    disp('Ingrese los porcentajes de intensidad para los 15 armónicos restantes (hasta 10 cifras decimales):');
    for i = 2:16
        while true
            value = input(sprintf('Armónico %d: ', i));
            % Validar entrada
            if isnumeric(value) && value >= 0 && value <= 100
                valueStr = sprintf('%.10f', value); % Formatear a 10 decimales
                valueRounded = str2double(valueStr); % Asegurar que tenga exactamente 10 decimales
                harmonicIntensities(i) = valueRounded;
                break;
            else
                disp('Entrada no válida. Ingrese un número entre 0 y 100 con hasta 10 cifras decimales.');
            end
        end
    end

    % Solicitar el nombre del instrumento
    instrumentName = input('Ingrese el nombre del nuevo instrumento: ', 's');

    % Crear vector de frecuencias de los armónicos
    harmonics = fundamentalFreq * (1:16);

    % Guardar en la base de datos
    saveToDatabase(instrumentName, fundamentalFreq, harmonics, harmonicIntensities);

    % Generar y reproducir el sonido inicial
    disp('Reproduciendo el sonido sintetizado...');
    generateSound(fundamentalFreq, harmonics, harmonicIntensities);

    % Bucle para reproducir el sonido con diferentes frecuencias
    while true
        userFreq = input('Ingrese otra frecuencia para reproducir el sonido (Oprime Enter para salir): ', 's');
        if isempty(userFreq)
            disp('Saliendo del programa.');
            break;
        else
            fundamentalFreq = str2double(userFreq);
            if isnan(fundamentalFreq) || fundamentalFreq <= 0
                disp('Entrada no válida. Intente nuevamente.');
            else
                harmonics = fundamentalFreq * (1:16);
                disp('Reproduciendo el sonido sintetizado con la nueva frecuencia...');
                generateSound(fundamentalFreq, harmonics, harmonicIntensities);
            end
        end
    end
end
