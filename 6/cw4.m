clc, clear, close all

load('anova_data.mat');

% H01 - średnie dla poszczególnych producentów są równe
% H02 - średnie dla typów maszyn są równe
% H03 - brak interakcji między producentem a typem maszyny
% Wykonanie dwuczynnikowej analizy wariancji
[p, tbl, stats] = anova2(popcorn, 3);

% Wyświetlenie wyników ANOVA
disp('Wyniki dwuczynnikowej ANOVA:');
fprintf('Czynnik kolumny (Producent): p = %.4f\n', p(1));
fprintf('Czynnik wierszy (Typ maszyny): p = %.4f\n', p(2));
fprintf('Interakcja: p = %.4f\n', p(3));

% Analiza post-hoc dla czynnika kolumny (producent)
figure;
[c_col, m_col] = multcompare(stats, 'Estimate', 'column');
title('Porównanie średnich dla producentów');

% Analiza post-hoc dla czynnika wierszy (typ maszyny)
figure;
[c_row, m_row] = multcompare(stats, 'Estimate', 'row');
title('Porównanie średnich dla typów maszyn');

if p(1) < 0.05
    fprintf('Średnie dla poszczególnych producentów są różne\n');
else
    fprintf('Średnie dla poszczególnych producentów są równe\n');
end

if p(2) < 0.05
    fprintf('Średnie dla poszczególnych typów maszyn są różne\n');
else
    fprintf('Średnie dla poszczególnych typów maszyn są równe\n');
end

if p(3) < 0.05
    fprintf('Wpływ producenta zależy od typu używanej maszyny\n');
else
    fprintf('Wpływ producenta nie jest zależy od typu używanej maszyny\n');
end