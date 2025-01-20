function mode = selectMode()
    disp('Seleccione un modo:');
    disp('0: Modo grabar (guardar en base de datos).');
    disp('1: Modo reconocer (identificar instrumento).');
    disp('2: Modo sintetizar (crear y guardar un nuevo instrumento).');
    mode = input('Ingrese su opción (0, 1 o 2): ');
    while ~ismember(mode, [0, 1, 2])
        disp('Opción no válida. Por favor, ingrese 0, 1 o 2.');
        mode = input('Ingrese su opción (0, 1 o 2): ');
    end
end