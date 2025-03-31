clc, clear, close all

data = readtable('3/dane/pacjenci.csv');
sugar = data.cukier;

% Test Shapiro-Wilka
[h_sw, p_sw, w_sw] = swtest(sugar, 0.05);
fprintf('Test Shapiro-Wilka dla cukru: h = %d, p = %.4f, W = %.4f\n', h_sw, p_sw, w_sw);

% Wykres QQ
figure;
qqplot(sugar);
title('Wykres QQ dla zmiennej cukier');