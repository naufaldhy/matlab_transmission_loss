function [STL,STC_N,requirements,val_STC] = tone_2(data_tone,set_STC_tone,room_vol,sample_area,reverb_time) 
    % Konversi SPL ke Rasio Tekanan (P / P0) dan perhitungan rata-rata SPL tiap
    % frekuensi
    pressure_ratio = 10.^(data_tone./20);
    average_SPL = 20.*log10(mean(pressure_ratio));
    
    % Noise reduction (NR) dan Rugi transmisi (STL)
    NR = zeros(16,1);
    for i = 1:length(average_SPL)/4-1
        NR(i) = abs(average_SPL(4*i-1) - average_SPL(4*i));
        NR(i+9) = abs(average_SPL(4*i-3) - average_SPL(4*i-2));
    end
    NR(8) = abs(average_SPL(29) - average_SPL(30));
    NR(9) = abs(average_SPL(31) - average_SPL(32));
    
    A = 0.161.*room_vol./reverb_time; % Total serapan dalam ruang penerima
    correction = 10*log10(sample_area./A);
    STL = NR + correction.*0.1; % 0.1 fraksi koreksi
    
    % Rumus empiris Sabine kurang cocok diterapkan pada ruang dengan penyerapan
    % tinggi, perhitungan total serapan dapat dilakukan dengan pendekatan lain
    
    % Sound transmission class
    max_attempts = 60; % cegah loop tak hingga
    attempt = 0;

    while true
        adjustment = [-16 -13 -10 -7 -4 -1 0 1 2 3 4 4 4 4 4 4];
        STC_N = set_STC_tone + adjustment';
        difference = STL - STC_N; % Gunakan NR daripada STL bila perlu
    
        requirements = zeros(16,1);
        for i = 1:length(requirements)
            if difference(i) < 0
                requirements(i) = difference(i);
            else
                requirements(i) = 0;
            end
        end

        if sum(requirements) >= -32 && sum(find(requirements < -8)) == 0
            break; % Kondisi terpenuhi
        end
    
        set_STC_tone = set_STC_tone - 1;
        attempt = attempt + 1;
    
        if attempt >= max_attempts
            warning("STC adjustment failed to meet criteria within max attempts");
            break;
        end
    end
    val_STC = set_STC_tone;
end