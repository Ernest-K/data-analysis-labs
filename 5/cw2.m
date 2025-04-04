clc, clear, close all

% Wczytanie danych
data = readtable('dane/czytelnictwo.csv');
przed = data.przed;
po = data.po;

% Analiza graficzna
figure;
boxplot([przed, po], 'Labels', {'Przed pracą', 'Po pracy'});
title('Czas poświęcany na lekturę prasy');

% H0: Podjęcie pracy w firmie nie miało wpływu na ilość czasu (przed = po)
% H1: Podjęcie pracy w firmie miało wpływ na ilość czasu (przed != po)

% Test znaków
[p_sign, h_sign, stats_sign] = signtest(przed, po);

fprintf('Wynik testu znaków:\n');
fprintf('p-wartość: %.4f\n', p_sign);
if h_sign == 1 
    fprintf('Odrzucamy hipotezę zerową: Podjęcie pracy w firmie miało wpływ.\n');
else
    fprintf('Brak podstaw do odrzucenia hipotezy zerowej: Podjęcie pracy w firmie nie miało wpływu.\n');
end