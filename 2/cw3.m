clc, clear

% H0: mu <= 3600
% H1: mu > 3600

mu0 = 3600;
x_mean = 3620;
s = 90;
n = 25;
alpha = 0.05;

x = normrnd(x_mean, s, [n, 1]);

[h, p] = ttest(x, mu0, "Tail", "right")

if h == 1
    disp("Odrzucamy hipotezę zerową")
else
    disp("Brak podstaw do odrzucenia hipotezy zerowej H0.")
end