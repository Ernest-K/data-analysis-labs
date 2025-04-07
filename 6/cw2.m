clc, clear, close all

load('anova_data.mat');

disp('# Testy normalnosci danych:');
% H0: Dane w danej grupie mają rozkład normalny.
% H1: Dane w danej grupie nie mają rozkładu normalnego.
groups = unique(wombat_groups);
figure;
for i = 1:length(groups)
    group_data = wombats(wombat_groups == groups(i));
    [h, p, stats] = swtest(group_data);
    if h == 1 
        fprintf('Odrzucamy hipoteze zerową: Próbka nie pochodzi z rozkładu normalnego\n');
    else 
        fprintf('Brak podstaw do odrzucenia hipotezy zerowej: Próbka pochodzi z rozkładu normalnego\n');
        
    end
    subplot(1, length(groups), i);
    qqplot(group_data);
end

% H0: Wariancje w trzech grupach są równe: σ₁² = σ₂² = σ₃².
% H1: Przynajmniej jedna z wariancji różni się od pozostałych.
disp('# Test wariancji danych:');
[p_var, stats_var] = vartestn(wombats', wombat_groups', 'Display', 'off');
fprintf('Bartlett''s test p-value: %.4f\n', p_var);

if p_var < 0.05 
    fprintf('Odrzucamy hipoteze zerową: Wariancje nie są równe\n');
else 
    fprintf('Brak podstaw do odrzucenia hipotezy zerowej: Wariancje są równe\n');
end

% H0: Średnie we wszystkich trzech grupach są równe (μ₁ = μ₂ = μ₃).
% H1: Przynajmniej jedna średnia różni się od pozostałych.
disp('# ANOVA:');
[p, tbl, stats] = anova1(wombats, wombat_groups);

if p < 0.05 
    fprintf('Odrzucamy hipoteze zerową: Średnie się różnią\n');
else 
    fprintf('Brak podstaw do odrzucenia hipotezy zerowej: Średnie są równe\n');
end