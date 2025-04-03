clc, clear, close all

nerwowi = [3, 3, 4, 5, 5];
spokojni = [4, 6, 7, 9, 9];

% testy normalności
disp("SW testy nerwowych, spokojnych")
[hn, pn] = swtest(nerwowi, 0.05);
fprintf("Nerwowi: h = %d, p = %.4f\n", hn, pn);
[hs, ps] = swtest(spokojni, 0.05);
fprintf("Spokojni: h = %d, p = %.4f\n", hs, ps);

figure;
subplot(1, 2, 1);
qqplot(nerwowi);
subplot(1, 2, 2);
qqplot(spokojni);

% Test na równość wariancji (test F)
[h_var, p_var] = vartest2(nerwowi, spokojni);

% Wybór t testu
if h_var == 0  % Jeśli wariancje są równe
    [h_t, p_t, ci, stats] = ttest2(nerwowi, spokojni, 'Vartype', 'equal', 'tail','right');
    fprintf('Test t dla równych wariancji (Student)\n');
else  % Jeśli wariancje są różne
    [h_t, p_t, ci, stats] = ttest2(nerwowi, spokojni, 'Vartype', 'unequal', 'tail','right');
    fprintf('Test t dla nierównych wariancji (Welcha)\n');
end

% H0: Średnia liczba gestów wykonywanych przez osoby nerwowe i osoby spokojne jest taka sama (μ_s =  μ_n)
% H1: Średnia liczba gestów wykonywanych przez osoby nerwowe jest większa niż u osób spokojnych (μ_s < μ_n)

% Wyniki
fprintf('Wartość statystyki t: %.4f\n', stats.tstat);
fprintf('Stopnie swobody: %.2f\n', stats.df);
fprintf('p-wartość: %.4f\n', p_t);
fprintf('Przedział ufności 95%%: [%.4f, %.4f]\n', ci(1), ci(2));

% Interpretacja wyniku
if h_t == 1
    fprintf('Odrzucamy hipotezę zerową: średnia liczba gestów osób nerwowych jest większa.\n');
else
    fprintf('Brak podstaw do odrzucenia hipotezy zerowej: średnia liczba gestów osób nerwowych i spokojnych jest taka sama.\n');
end
