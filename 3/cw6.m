clc, clear, close all

% Wczytanie danych (jeśli nie zostały wczytane wcześniej)
data = readtable('3/dane/pacjenci.csv');
height_men = data.wzrost(strcmp(data.plec,'M'));
height_women = data.wzrost(strcmp(data.plec, 'K'));

% Test K-S dla wzrostu mężczyzn
[h_men, p_men, ksstat_men] = kstest(height_men, [height_men, normcdf(height_men, mean(height_men), std(height_men, 1))], 0.05);
fprintf('Test K-S dla wzrostu mężczyzn: h = %d, p = %.4f\n', h_men, p_men);

% Test K-S dla wzrostu kobiet
[h_women, p_women, ksstat_women] = kstest(height_women, [height_women, normcdf(height_women, mean(height_women), std(height_women, 1))], 0.05);
fprintf('Test K-S dla wzrostu kobiet: h = %d, p = %.4f\n', h_women, p_women);

% Test Lillieforsa dla wzrostu mężczyzn
[h_men_lillie, p_men_lillie, stat_men_lillie, cv_men_lillie] = lillietest(height_men);
fprintf('Test Lillieforsa dla wzrostu mężczyzn: h = %d, p = %.4f\n', h_men_lillie, p_men_lillie);

% Test Lillieforsa dla wzrostu kobiet
[h_women_lillie, p_women_lillie, stat_women_lillie, cv_women_lillie] = lillietest(height_women);
fprintf('Test Lillieforsa dla wzrostu kobiet: h = %d, p = %.4f\n', h_women_lillie, p_women_lillie);

% Porównanie z wynikami testu K-S
fprintf('Porównanie wyników testów dla mężczyzn: K-S p = %.4f, Lillieforsa p = %.4f\n', p_men, p_men_lillie);
fprintf('Porównanie wyników testów dla kobiet: K-S p = %.4f, Lillieforsa p = %.4f\n', p_women, p_women_lillie);