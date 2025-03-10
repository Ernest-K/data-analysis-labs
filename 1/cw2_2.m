clc;
clear;
close all;

x1 = 2 * (randn(100,1) + 1); % 100 losowych liczb z rozkładu normalnego (średnia = 1, odchylenie standardowe = 2)
x2 = 3 * (randn(100,1) - 1); % 100 losowych liczb z rozkładu normalnego (średnia = -1, odchylenie standardowe = 3)

z = [x1 x2]; 

subplot(211)  % Tworzenie pierwszego wykresu w układzie 2x1 (dwa wykresy, pierwszy na górze)
boxplot(z,1)

% wykres pudełkowy/skrzynkowy
% wartości odstające
% górne ekstremum
% górny kwartyl
% mediana 
% dolny kwartyl
% dolne ekstremum
% wartości odstające

subplot(212)
histogram(z)