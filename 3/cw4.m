clc, clear, close all

data = readtable('3/dane/pacjenci.csv');
height_men = data.wzrost(strcmp(data.plec,'M'));
height_women = data.wzrost(strcmp(data.plec, 'K'));

% Test normalności dla wzrostu mężczyzn
[h_men, p_men, ksstat_men] = kstest(height_men, [height_men, normcdf(height_men, mean(height_men), std(height_men, 1))], 0.05);
fprintf('Test K-S dla wzrostu mężczyzn: h = %d, p = %.4f\n', h_men, p_men);

% Test normalności dla wzrostu kobiet
[h_women, p_women, ksstat_women] = kstest(height_women, [height_women, normcdf(height_women, mean(height_women), std(height_women, 1))], 0.05);
fprintf('Test K-S dla wzrostu kobiet: h = %d, p = %.4f\n', h_women, p_women);

% Test porównania obu rozkładów
[h_compare, p_compare, ksstat_compare] = kstest2(height_men, height_women);
fprintf('Test K-S dla porównania wzrostu mężczyzn i kobiet: h = %d, p = %.4f\n', h_compare, p_compare);

figure;
subplot(2,1,1);
qqplot(height_men);
title('Wykres Q-Q plot dla wzrostu mężczyzn');
subplot(2,1,2)
qqplot(height_women);
title('Wykres Q-Q plot dla wzrostu kobiet');

figure;
cdfplot(height_men);
hold;
cdfplot(height_women);