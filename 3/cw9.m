clc, clear, close all

% Wczytanie danych
capacitors = readtable('3/dane/kondensatory.csv');
capacitor_capacity = capacitors.pojemnosc; % Zakładam, że dane są w pierwszej kolumnie

% Test Shapiro-Wilka z poziomem istotności 0.05
[h_capacitors, p_capacitors, w_capacitors] = swtest(capacitor_capacity, 0.05);
fprintf('Test Shapiro-Wilka dla pojemności kondensatorów: h = %d, p = %.4f, W = %.4f\n', h_capacitors, p_capacitors, w_capacitors);

% Wykres QQ
figure;
qqplot(capacitor_capacity);
title('Wykres QQ dla pojemności kondensatorów');