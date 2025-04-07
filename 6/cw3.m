clc, clear, close all

shops = 1:14;
quarter1 = [3415 1593 1976 1526 1538 983 1050 1861 1714 1320 1276 1263 1271 1436];
quarter2 = [4556 1937 2056 1594 1634 1086 1209 2087 2415 1621 1377 1279 1417 1310];
quarter3 = [5772 2242 2240 1644 1866 1135 1245 2054 2361 1624 1522 1350 1583 1357];
quarter4 = [5432 2794 2085 1705 1769 1177 977 2018 2424 1551 1412 1490 1513 1468];

sales_data = [quarter1' quarter2' quarter3' quarter4'];

% Mamy dane zależne/powiązane, bo to są wielokrotne pomiary dla tych samych sklepów → test Friedmana.
% Test Kruskala-Wallisa służy do porównywania niezależnych grup. Na przykład: Gdybyś porównywał różne sklepy w tym samym kwartale,

% H0: Sprzedaż jest taka sama pomiędzy quater
% H1: Sprzedaż jest różna pomiędzy quater

[p, table, stats] = friedman(sales_data, 1);
fprintf('Friedman test p-value: %.4f\n', p);
if p < 0.05
    fprintf('Odrzucamy hipotezę zerową: Sprzedaż jest różna pomiędzy quater.\n');
    figure;
    [c, m] = multcompare(stats, 'Display', 'on');
else
    fprintf('Brak podstaw do odrzucenia hipotezy zerowej: Sprzedaż jest taka sama pomiędzy quater.\n');
end