clc, clear, close all

dane = [4.64 5.12 4.64 3.21 3.92 4.95 3.75 2.95 2.95;
        5.92 6.10 4.32 3.17 3.75 5.22 2.50 3.21 2.80;
        5.25 4.85 4.13 3.88 4.01 5.16 2.65 3.15 3.63;
        6.17 4.72 5.17 3.50 4.64 5.35 2.84 3.25 3.85;
        4.20 5.36 3.77 2.47 3.63 4.35 3.09 2.30 2.19;
        5.90 5.41 3.85 4.12 3.46 4.89 2.90 2.76 3.32;
        5.07 5.31 4.12 3.51 4.01 5.61 2.62 3.01 2.68;
        4.13 4.78 5.07 3.85 3.39 4.98 2.75 2.31 3.35;
        4.07 5.08 3.25 4.22 3.78 5.77 3.10 2.50 3.12;
        5.30 4.97 3.49 3.07 3.51 5.23 1.99 2.02 4.11;
        4.37 5.85 3.65 3.62 3.19 4.76 2.42 2.64 2.90;
        3.76 5.26 4.10 2.95 4.04 5.15 2.37 2.27 2.75];

disp('# Testy normalnosci danych:');
for x = 1:9
    [h, p, stats] = swtest(dane(:,x));
    if h == 1 
        fprintf('Odrzucamy hipoteze zerową: Próbka nie pochodzi z rozkładu normalnego\n');
    else 
        fprintf('Brak podstaw do odrzucenia hipotezy zerowej: Próbka pochodzi z rozkładu normalnego\n');
    end
    subplot(1, 9, x);
    qqplot(dane(:, x));
end

disp('# Test rownosci wariancji')
[p_var, stats_var] = vartestn(dane);
fprintf('Bartlett''s test p-value: %.4f\n', p_var);

if p_var < 0.05 
    fprintf('Odrzucamy hipoteze zerową: Wariancje nie są równe\n');
else 
    fprintf('Brak podstaw do odrzucenia hipotezy zerowej: Wariancje są równe\n');
end

disp('# Test ANOVA2');
p = anova2([dane(:, 1:3); dane(:, 4:6); dane(:, 7:9)], 12)

%H01 - średnia wydolnośc dla każdego zakładu jest jednakowa
%H02 - średnia wydolność jest niezależna od rodzaju substancji
%H03 - zakład i rodzaj substancji nie mają wpływu na średnią wydolność wydechu