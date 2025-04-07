clc, clear, close all

load('anova_data.mat');

disp('# Testy normalnosci danych:');

% H0: Dane w danej grupie mają rozkład normalny.
% H1: Dane w danej grupie nie mają rozkładu normalnego.
figure;
for x = 1:3
	[h, p, stats] = swtest(koala(:, x));
    if h == 1 
        fprintf('Odrzucamy hipoteze zerową: Próbka nie pochodzi z rozkładu normalnego\n');
    else 
        fprintf('Brak podstaw do odrzucenia hipotezy zerowej: Próbka pochodzi z rozkładu normalnego\n');
    end
    subplot(1, 3, x);
    qqplot(koala(:, x));
end

% H0: Wariancje w trzech grupach są równe: σ₁² = σ₂² = σ₃².
% H1: Przynajmniej jedna z wariancji różni się od pozostałych.
disp('# Test wariancji danych:');
[p_var, stats_var] = vartestn(koala, 'Display', 'off');
fprintf('Bartlett''s test p-value: %.4f\n', p_var);

if p_var < 0.05 
    fprintf('Odrzucamy hipoteze zerową: Wariancje nie są równe\n');
else 
    fprintf('Brak podstaw do odrzucenia hipotezy zerowej: Wariancje są równe\n');
end

% H0: Średnie czasy snu we wszystkich trzech grupach zwierząt są równe (μ₁ = μ₂ = μ₃).
% H1: Przynajmniej jedna średnia czasu snu różni się od pozostałych.
disp('# ANOVA:');
[p, tbl, stats] = anova1(koala);

if p < 0.05 
    fprintf('Odrzucamy hipoteze zerową: Średnie się różnią \n');
else 
    fprintf('Brak podstaw do odrzucenia hipotezy zerowej: Średnie są równe\n');
end