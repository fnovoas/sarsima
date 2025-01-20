function base_datos = initializeDatabase()
    if exist('harmonic_db.mat', 'file')
        load('harmonic_db.mat', 'base_datos');
    else
        base_datos = {};
    end
end