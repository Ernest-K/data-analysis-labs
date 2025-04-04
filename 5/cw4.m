clc, clear, close all

% Wczytanie danych
data = readtable('dane/czytelnictwo.csv');
przed = data.przed;
po = data.po;

% test normalności
[h1, p1] = swtest(przed, 0.05);
fprintf("SW test przed: h = %d, p = %.4f\n", h1, p1);
[h2, p2] = swtest(po, 0.05);
fprintf("SW test po: h = %d, p = %.4f\n", h2, p2);

if h1 == 0 && h2 == 0
    fprintf('Rozkłady wyników są zbliżone do rozkładu normalnego\n');
else
    fprintf('Rozkłady wyników NIE są zbliżone do rozkładu normalnego\n');
end
