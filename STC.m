clc
clear all

% Fetch data white noise dan tone dari 125 Hz sampai 4000 Hz
data_WN = readmatrix("wn.csv","Range","S2:AX16");

files = dir("*.csv");
index = ["AK2:AL16","S2:T16","AM2:AN16","U2:V16","AO2:AP16","W2:X16","AQ2:AR16","Y2:Z16","AS2:AT16","AA2:AB16","AU2:AV16","AC2:AD16","AW2:AX16","AE2:AF16","AG2:AH16","AI2:AJ16"];

tone(:,:,1) = readmatrix(files(1).name,"Range",index(1));
data_tone = zeros(15,32);
for i = 1:16
    tone(:,:,i) = 0;
    tone(:,:,i) = readmatrix(files(i).name,"Range",index(i));
    data_tone(:,2*i-1) = tone(:,1,i);
    data_tone(:,2*i) = tone(:,2,i);
end

% Parameter input
reverb_time = readmatrix("RT.xlsx","Range","B2:B17"); % column C untuk ruang reverb ; B anechoic
frequency = readmatrix("RT.xlsx","Range","A2:A17");
room_vol = 72; % V_anechoic = 72 m^2 ; V_reverb = 140 m^3
sample_area = 1.01; % dalam m^2
set_STC_tone = 65;
set_STC_white = 65;

% Fungsi untuk mendapatkan STC dan STL
[STL_w,STC_N_w,req_white,val_STC_white] = wn_2(data_WN,set_STC_white,room_vol,sample_area,reverb_time);
[STL_t,STC_N_t,req_tone,val_STC_tone] = tone_2(data_tone,set_STC_tone,room_vol,sample_area,reverb_time);

% Plotting
semilogx(frequency,STL_w,"b--^","MarkerFaceColor","b");
hold on
semilogx(frequency,STC_N_w,"r--o","MarkerFaceColor","r");
ylim([min(STL_w)-20 max(STL_w)+20]);
xlim([100 5000])
xlabel("Frequency (Hz)");
ylabel("STL (dB)");
legend('STL', sprintf('STC = %d', val_STC_white), 'Location', 'best');
set(gca, 'XTick', frequency);                  % Set all desired frequencies as ticks
set(gca, 'XTickLabel', string(frequency));     % Display them as plain numbers
grid on