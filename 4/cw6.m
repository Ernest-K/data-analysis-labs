clc, clear, close all

% Dane
data17 = [172.72,157.48,170.18,172.72,175.26,170.18,154.94,149.86,157.48,...
          154.94,175.26,167.64,157.48,157.48,154.94,177.8];

% test normalności
[h1, p1] = swtest(data17, 0.05);
fprintf("SW test: h = %d, p = %.4f\n", h1, p1);

if h1 == 0
    fprintf('Rozkład wyników jest zbliżony do rozkładu normalnego\n');
else
    fprintf('Rozkład wyników NIE jest zbliżony do rozkładu normalnego\n');
end

% Wartość testowa (hipotetyczna średnia)
mu0 = 164.1475;

% H0: Średni wzrost studentów z grupy o 17:00 wynosi 164.1475 cm (μ = 164.1475)
% H1: Średni wzrost studentów różni się od 164.1475 cm (μ != 164.1475)

% Test t dla jednej próbki
alpha = 0.05; % Poziom istotności
[h_t, p_t, ci, stats] = ttest(data17, mu0, 'Alpha', alpha);

% Wyniki
fprintf('Wartość statystyki t: %.4f\n', stats.tstat);
fprintf('Stopnie swobody: %d\n', stats.df);
fprintf('p-wartość: %.4f\n', p_t);
fprintf('Przedział ufności 95%%: [%.4f, %.4f]\n', ci(1), ci(2));

% Interpretacja wyniku
if p_t < alpha
    fprintf('Odrzucamy hipotezę zerową: średni wzrost różni się istotnie od %.4f cm.\n', mu0);
else
    fprintf('Brak podstaw do odrzucenia hipotezy zerowej: średni wzrost nie różni się istotnie od %.4f cm.\n', mu0);
end