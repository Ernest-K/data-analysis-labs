clc, clear, close all

% Dane
data13 = [175.26, 177.8, 167.64, 160.02, 172.72, 177.8, 175.26, 170.18, 157.48, 160.02, ...
          193.04, 149.86, 157.48, 157.48, 190.5, 157.48, 182.88, 160.02];

data17 = [172.72, 157.48, 170.18, 172.72, 175.26, 170.18, 154.94, 149.86, 157.48, 154.94, ...
          175.26, 167.64, 157.48, 157.48, 154.94, 177.8];

% H0: Rozkłady wzrostów studentów w obu grupach są takie same
% H1: Rozkłady wzrostów studentów w obu grupach są różne

alpha = 0.05;

% Test Manna-Whitneya-Wilcoxona (mwwtest)
stats = mwwtest(data13, data17);

% Interpretacja wyniku
if stats.p(2) < alpha
    fprintf('Odrzucamy hipotezę zerową: jest istotna różnica we wzrostach między grupami.\n');
else
    fprintf('Brak podstaw do odrzucenia hipotezy zerowej: nie ma istotnej różnicy we wzrostach między grupami.\n');
end