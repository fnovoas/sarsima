function app()
    % Crear la ventana principal
    fig = uifigure('Name', 'Procesamiento de Audio', 'Position', [100, 100, 400, 300]);

    % Menú desplegable para seleccionar el modo
    lblModo = uilabel(fig, 'Text', 'Seleccione el modo:', 'Position', [50, 230, 120, 20]);
    modoDropdown = uidropdown(fig, 'Items', {'Grabar', 'Reconocer', 'Sintetizar'}, ...
                              'Position', [180, 230, 120, 25]);

    % Botón para ejecutar el modo seleccionado
    btnEjecutar = uibutton(fig, 'Text', 'Ejecutar', 'Position', [150, 180, 100, 30], ...
                           'ButtonPushedFcn', @(btn, event) ejecutarModo(modoDropdown.Value));

    % Etiqueta para mostrar mensajes
    lblMensaje = uilabel(fig, 'Text', '', 'Position', [50, 140, 300, 30], 'FontSize', 12, ...
                         'HorizontalAlignment', 'center');

    % Función que ejecuta la acción basada en la selección del usuario
    function ejecutarModo(modoSeleccionado)
        switch modoSeleccionado
            case 'Grabar'
                lblMensaje.Text = 'Grabando...';
                grabarNota(); % Llamar a la función personalizada
                lblMensaje.Text = 'Nota grabada y guardada.';
            case 'Reconocer'
                lblMensaje.Text = 'Reconociendo...';
                reconocerInstrumento();
                lblMensaje.Text = 'Instrumento reconocido.';
            case 'Sintetizar'
                lblMensaje.Text = 'Sintetizando...';
                sintetizarInstrumento();
                lblMensaje.Text = 'Síntesis completada.';
        end
    end
end