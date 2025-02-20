function synthesizeInstrument()
    global base_datos;
    global instrumento_sintetizado;  % Declarar la variable global dentro de la función

    % Usar la frecuencia fundamental predeterminada de 440 Hz
    fundamentalFreq = 440;

    % Solicitar al usuario los porcentajes de intensidad para los 15 armónicos restantes (hasta 10 cifras decimales)
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

    % Solicitar el nombre del nuevo instrumento
    instrumentName = input('Ingrese el nombre del nuevo instrumento: ', 's');

    % Crear vector de frecuencias de los armónicos
    harmonics = fundamentalFreq * (1:16);

    % Guardar en la base de datos
    saveToDatabase(instrumentName, fundamentalFreq, harmonics, harmonicIntensities);

    % Asignar los valores del instrumento sintetizado a la variable global
    instrumento_sintetizado.fundamentalFreq = fundamentalFreq;
    instrumento_sintetizado.harmonicIntensities = harmonicIntensities;

    % Lanzar directamente el piano con el instrumento sintetizado
    disp('Lanzando el piano con el instrumento sintetizado...');
    piano;
end
