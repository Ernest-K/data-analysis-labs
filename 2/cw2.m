clc, clear 

% H0: mu = 3
% H1: mu != 3

x = [1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 4, 4, 4, 4, 4, 5, 5, 6, 6, 6, 7, 7];

mu0 = 3;
x_mean = mean(x);
s = std(x);
n = 22;

[h, p] = ttest(x, mu0)

if h == 1
    disp("Odrzucamy hipotezę zerową")
else
    disp("Brak podstaw do odrzucenia hipotezy zerowej H0.")
end