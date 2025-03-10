clc, clear

% H0: mu = 28
% H1: mu != 28

mu0 = 28;
x_mean = 31.5;
s = 5;
n = 100;
a = 0.05;

% Obliczenia ręczne 
z = (x_mean - mu0) / s * sqrt(n)
p_value = 2 * (1 - tcdf(abs(z), n-1))

% Wykorzystanie funkcji
x = normrnd(x_mean, s, [n, 1]);
[h, p, ci, stats] = ttest(x, mu0)

% Sprawdzenie
z_f = (mean(x) - mu0) / std(x) * sqrt(n);
p_value_f = 2 * (1 - tcdf(abs(z_f), n-1));

if p <= a
    disp("Odrzucamy hipotezę zerową")
else
    disp("Brak podstaw do odrzucenia hipotezy zerowej H0.")
end
