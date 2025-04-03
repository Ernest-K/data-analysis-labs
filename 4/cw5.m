clc, clear, close all

% Dane
data13 = [175.26, 177.8, 167.64, 160.02, 172.72, 177.8, 175.26, 170.18, 157.48, ...
          160.02, 193.04, 149.86, 157.48, 157.48, 190.5, 157.48, 182.88, 160.02];

% test normalności
[h1, p1] = swtest(data13, 0.05);
fprintf("SW test: h = %d, p = %.4f\n", h1, p1);

if h1 == 0
    fprintf('Rozkład wyników jest zbliżony do rozkładu normalnego\n');
else
    fprintf('Rozkład wyników NIE jest zbliżony do rozkładu normalnego\n');
end

qqplot(data13);

% Wartość testowa (hipotetyczna średnia)
mu0 = 169.051;

% H0: Średni wzrost studentów z grupy o 13:00 wynosi 169.051 cm (μ = 169.051)
% H1: Średni wzrost studentów różni się od 169.051 cm (μ != 169.051)

% Test t dla jednej próbki
alpha = 0.05; % Poziom istotności
[h_t, p_t, ci, stats] = ttest(data13, mu0, 'Alpha', alpha);

% Wyniki
fprintf('Wartość statystyki t: %.4f\n', stats.tstat);
fprintf('Stopnie swobody: %d\n', stats.df);
fprintf('p-wartość: %.4f\n', p_t);
fprintf('Przedział ufności 95%%: [%.4f, %.4f]\n', ci(1), ci(2));

% Interpretacja wyniku
if p_t < alpha
    fprintf('Odrzucamy hipotezę zerową: średni wzrost różni się istotnie od %.3f cm.\n', mu0);
else
    fprintf('Brak podstaw do odrzucenia hipotezy zerowej: średni wzrost nie różni się istotnie od %.3f cm.\n', mu0);
end
