clc, clear, close all

% Wczytanie danych
graduates = readtable('3/dane/absolwenci.csv');
agriculture_salary = graduates.SALARY(strcmp(graduates.COLLEGE, 'Rolnictwo'));
pedagogy_salary = graduates.SALARY(strcmp(graduates.COLLEGE, 'Pedagogika'));

% Test Shapiro-Wilka dla rolnictwa
[h_agri, p_agri, w_agri] = swtest(agriculture_salary, 0.05);
fprintf('Test Shapiro-Wilka dla płac absolwentów rolnictwa: h = %d, p = %.4f, W = %.4f\n', h_agri, p_agri, w_agri);

% Test Shapiro-Wilka dla pedagogiki
[h_ped, p_ped, w_ped] = swtest(pedagogy_salary, 0.05);
fprintf('Test Shapiro-Wilka dla płac absolwentów pedagogiki: h = %d, p = %.4f, W = %.4f\n', h_ped, p_ped, w_ped);

% Wykresy QQ
figure;
subplot(1, 2, 1);
qqplot(agriculture_salary);
title('Wykres QQ dla płac absolwentów rolnictwa');

subplot(1, 2, 2);
qqplot(pedagogy_salary);
title('Wykres QQ dla płac absolwentów pedagogiki');

% Objaśnienie wyboru testu
fprintf('\nDo testowania normalności rozkładu płac użyto testu Shapiro-Wilka, ponieważ jest on rekomendowany jako najbardziej skuteczny test normalności, szczególnie dla próbek o mniejszej liczbie obserwacji. Test ten ma większą moc od testów K-S i Lillieforsa w wykrywaniu odstępstw od normalności.\n');