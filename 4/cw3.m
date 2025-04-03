clc, clear, close all

mniej30 = [6, 7, 10, 9];
po30 = [5, 6, 2, 3];

% testy normalności
disp("SW testy")
[h1, p1] = swtest(mniej30, 0.05);
fprintf("poniżej 30: h = %d, p = %.4f\n", h1, p1);
[h2, p2] = swtest(po30, 0.05);
fprintf("powyżej 30: h = %d, p = %.4f\n", h2, p2);

figure;
subplot(1, 2, 1);
qqplot(mniej30);
subplot(1, 2, 2);
qqplot(po30);

% Test na równość wariancji (test F)
[h_var, p_var] = vartest2(mniej30, po30);

% Poziom istotności
alpha = 0.05; 

if h_var == 0  % Jeśli wariancje są równe
    [h_t, p_t, ci, stats] = ttest2(mniej30, po30, 'Vartype', 'equal', 'Tail', 'right', 'Alpha', alpha);
    fprintf('Test t dla równych wariancji (Student)\n');
else  % Jeśli wariancje są różne
    [h_t, p_t, ci, stats] = ttest2(mniej30, po30, 'Vartype', 'unequal', 'Tail', 'right', 'Alpha', alpha);
    fprintf('Test t dla nierównych wariancji (Welcha)\n');
end

% H0: Średni współczynnik rozbawienia osób poniżej 30 lat i po 30 latach jest taki sam (μ_m = μ_p)
% H1: Osoby poniżej 30 są bardziej dowcipne (μ_m > μ_p)

% Wyniki
fprintf('Wartość statystyki t: %.4f\n', stats.tstat);
fprintf('Stopnie swobody: %.2f\n', stats.df);
fprintf('p-wartość: %.4f\n', p_t);
fprintf('Przedział ufności 95%% (dolna granica): %.4f\n', ci(1));

% Interpretacja wyniku
if p_t < alpha
    fprintf('Odrzucamy hipotezę zerową: osoby poniżej 30 są istotnie bardziej dowcipne.\n');
else
    fprintf('Brak podstaw do odrzucenia hipotezy zerowej: nie ma istotnej różnicy w rozbawieniu.\n');
end
