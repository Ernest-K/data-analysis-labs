clc, clear, close all

% Wczytanie danych
chmiel_data = readtable('dane/chmiel.csv');
niezapylone = chmiel_data.niezapyl;
zapylone = chmiel_data.zapylona;

% Analiza graficzna
figure;
boxplot([niezapylone, zapylone], 'Labels', {'Niezapylone', 'Zapylone'});
title('Masa nasion chmielu');

% H0: Zapylenie nie ma wpływu na masę nasion (zapylone = niezapylone)
% H1: Zapylenie ma wpływ na masę nasion (zapylone != niezapylone)

% Test Wilcoxona przy poziomie istotności 0.05
[p, h, stats] = signrank(niezapylone, zapylone, 'alpha', 0.05);

fprintf('Wynik testu Wilcoxona dla nasion chmielu:\n');
fprintf('p-wartość: %.4f\n', p);
if h == 1 
    fprintf('Odrzucamy hipotezę zerową: Zapylenie miało wpływ.\n');
else
    fprintf('Brak podstaw do odrzucenia hipotezy zerowej: Zapylenie nie miało wpływu.\n');
end