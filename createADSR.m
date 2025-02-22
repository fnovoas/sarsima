function envelope = createADSR(A, D, S, R, dur, fs)
    t = linspace(0, dur, round(fs * dur));
    
    % Crear cada tramo de la envolvente
    attack = linspace(0, 1, round(A * fs));
    decay = linspace(1, S, round(D * fs));
    sustain = linspace(S, S, round((dur - A - D - R) * fs));
    release = linspace(S, 0, round(R * fs));
    
    envelope = [attack, decay, sustain, release];
    
    % Asegurarse que la envolvente tenga la longitud correcta
    if length(envelope) < length(t)
        envelope = [envelope, zeros(1, length(t) - length(envelope))];
    elseif length(envelope) > length(t)
        envelope = envelope(1:length(t));
    end
end
