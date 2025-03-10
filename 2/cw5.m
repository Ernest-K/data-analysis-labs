clc, clear

% Nabywcy nowego produktu:
n1 = 20;                 % Liczba nabywców nowego produktu
mean1 = 27.7;            % Średnia wieku
std1 = 5.5;              % Odchylenie standardowe wieku

% Nabywcy znanego produktu:
n2 = 22;                 % Liczba nabywców znanego produktu
mean2 = 32.1;            % Średnia wieku
std2 = 6.3;              % Odchylenie standardowe wieku

grupa1 = normrnd(mean1, std1, [n1, 1]);
grupa2 = normrnd(mean2, std2, [n2, 1]);

[h, p, ci, stats] = vartest2(grupa1, grupa2);

if h == 0
    disp('Odchylenia standardowe wieku nabywców obu produktów nie różnią się istotnie.');
else
    disp('Odchylenia standardowe wieku nabywców obu produktów różnią się istotnie.');
end