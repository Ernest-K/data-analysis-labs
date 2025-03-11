clc, clear, close all

mu = 3; % Wartość oczekiwana
sigma = 4; % Odchylenie standardowe

n = 1000;

data = sigma * randn(n, 1) + mu;

subplot(1,2,1);
histogram(data)
title('Histogram rozkładu N(3,4)');

subplot(1,2,2);
cdfplot(data);
title('Dystrybuanta rozkładu N(3,4)');