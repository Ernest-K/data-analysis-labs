clc, clear, close all

controlA = [0.22, -0.87, -2.39, -1.79, 0.37, -1.54, 1.28, -0.31, -0.74, 1.72, 0.38, -0.17, -0.62, -1.10, 0.30, 0.15, 2.30, 0.19, -0.50, -0.09];
treatmentA = [-5.13, -2.19, -2.43, -3.83, 0.50, -3.25, 4.32, 1.63, 5.18, -0.43, 7.11, 4.87, -3.10, -5.81, 3.76, 6.31, 2.58, 0.07, 5.76, 3.50];

n_controlA = length(controlA);
x_controlA = sort(controlA);
y_controlA = (1:n_controlA) / n_controlA;

n_treatmentA = length(treatmentA);
x_treatmentA = sort(treatmentA);
y_treatmentA = (1:n_treatmentA) / n_treatmentA;

% Rysowanie wykresu
figure;
plot(x_controlA, y_controlA, 'bo-')
hold;
plot(x_treatmentA, y_treatmentA, 'ro-');
title('Dystrybuanty dla zbiorów controlA i treatmentA');
xlabel('Wartość');
ylabel('Dystrybuanta F(x)');
legend('controlA', 'treatmentA');
grid on;

% Test K-S
[h, p, ksstat] = kstest2(controlA, treatmentA);
fprintf('Test K-S dla controlA i treatmentA: h = %d, p = %.4f, D = %.4f\n', h, p, ksstat);