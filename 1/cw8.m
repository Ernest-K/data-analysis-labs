clc, clear

czasy = [8.5, 7.6, 9.3, 5.5, 11.4, 6.9, 6.5, 12.9, 8.7, 4.8, 4.2, 8.1, 6.5, 5.8, 6.7, 2.4, 11.1, 7.1, 8.8, 7.2];

srednia = mean(czasy)
mediana = median(czasy)
odchylenie_standardowe = std(czasy)

subplot(1, 2, 1);
boxplot(czasy);

subplot(1, 2, 2);
histogram(czasy);
