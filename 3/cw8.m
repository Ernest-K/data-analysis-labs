clc, clear, close all

bulbs = readtable('3/dane/zarowki.csv');
bulbs_time = bulbs.czas;

% Test Shapiro-Wilka z poziomem istotności 0.1
[h_bulbs, p_bulbs, w_bulbs] = swtest(bulbs_time, 0.1);
fprintf('Test Shapiro-Wilka dla czasu zużycia żarówek: h = %d, p = %.4f, W = %.4f\n', h_bulbs, p_bulbs, w_bulbs);

% Wykres QQ
figure;
qqplot(bulbs_time);
title('Wykres QQ dla czasu zużycia żarówek');