clc, clear, close all

% Dane
nerwowi = [3, 3, 4, 5, 5];
spokojni = [4, 6, 7, 9, 9];

% H0: Rozkłady liczby gestów w obu grupach są takie same 
% H1: Rozkłady liczby gestów w obu grupach są różne

alpha = 0.05;

% Test Manna-Whitneya-Wilcoxona (mwwtest)
stats = mwwtest(nerwowi, spokojni);

% Interpretacja wyniku
if stats.p(2) < alpha
    fprintf('Odrzucamy hipotezę zerową: liczba gestów różni się istotnie między grupami.\n');
else
    fprintf('Brak podstaw do odrzucenia hipotezy zerowej: nie ma istotnej różnicy w liczbie gestów.\n');
end