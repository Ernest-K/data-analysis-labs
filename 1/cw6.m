clc, clear, close all

mu = 3; % Wartość oczekiwana
sigma = 2; % Odchylenie standardowe (pierwiastek z wariancji - 4)

n = 1000;

data = sigma * randn(n, 1) + mu;

subplot(1,2,1);
histogram(data)
subplot(1,2,2);
title('Histogram rozkładu N(3,4)');

subplot(1,2,2);
cdfplot(data);
title('Dystrybuanta rozkładu N(3,4)');