clc, clear, close all

% Wczytanie danych
koronografia_data = readtable('dane/dane z koronografii.csv');
time = koronografia_data.time;
group = koronografia_data.group;

% Rozdzielenie danych na grupy
time_chorzy = time(group == 1);
time_zdrowi = time(group == 2);

% H0: Czas ćwiczenia nie jest zależny od stanu zdrowia (chorzy = zdrowi)
% H1: Czas ćwiczenia jest zależny od stanu zdrowia (chorzy != zdrowi)

% Test Wilcoxona-Manna-Whitneya dla prób niezależnych (ranksum)
% przy poziomie istotności 0.1 (poziom ufności 0.9)
[p, h, stats] = ranksum(time_chorzy, time_zdrowi, 'alpha', 0.1);

fprintf('Wynik testu dla danych z koronografii:\n');
fprintf('p-wartość: %.4f\n', p);
fprintf('Statystyka U: %d\n', stats.ranksum);
if h == 1 
    fprintf('Odrzucamy hipotezę zerową: Czas ćwiczenia jest zależny od stanu zdrowia.\n');
else
    fprintf('Brak podstaw do odrzucenia hipotezy zerowej: Czas ćwiczenia nie jest zależny od stanu zdrowia.\n');
end
