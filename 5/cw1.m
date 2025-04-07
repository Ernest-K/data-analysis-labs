clc, clear, close all

w1 = [88 69 86 59 57 82 94 93 64 91 86 59 91 60 57 92 70 88 70 85];
w2 = [73 68 75 54 53 84 84 86 66 84 78 58 91 57 59 88 71 84 64 85];

% Analiza graficzna
figure;
boxplot([w1', w2'], 'Labels', {'Przed dietą', 'Po diecie'});

% H0: Dieta nie powoduje zmniejszenie ciężaru ciała (w1 = w2)
% H1: Dieta powoduje zmniejszenie ciężaru ciała (w1 > w2)

[p_sign, h_sign, stats_sign] = signtest(w1, w2, 'alpha', 0.05, 'tail', 'right');

fprintf('Wynik testu znaków:\n');
fprintf('p-wartość: %.4f\n', p_sign);
fprintf('Liczba znaków dodatnich: %d\n', stats_sign.sign);
if h_sign == 1 
    fprintf('Odrzucamy hipotezę zerową: Dieta powoduje zmniejszenie ciężaru ciała.\n');
else
    fprintf('Brak podstaw do odrzucenia hipotezy zerowej: Dieta nie powoduje zmniejszenia ciężaru ciała.\n');
end