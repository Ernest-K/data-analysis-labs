clc, clear, close all

% Dane
delikates = [23.4, 30.9, 18.8, 23.0, 21.4, 1, 24.6, 23.8, 24.1, 18.7, 16.3, 20.3, 14.9, 35.4, 21.6, 21.2, 21.0, 15.0, 15.6, 24.0, 34.6, 40.9, 30.7, 24.5, 16.6, 1, 21.7, 1, 23.6, 1, 25.7, 19.3, 46.9, 23.3, 21.8, 33.3, 24.9, 24.4, 1, 19.8, 17.2, 21.5, 25.5, 23.3, 18.6, 22.0, 29.8, 33.3, 1, 21.3, 18.6, 26.8, 19.4, 21.1, 21.2, 20.5, 19.8, 26.3, 39.3, 21.4, 22.6, 1, 35.3, 7.0, 19.3, 21.3, 10.1, 20.2, 1, 36.2, 16.7, 21.1, 39.1, 19.9, 32.1, 23.1, 21.8, 30.4, 19.62, 15.5];
renety = [16.5, 1, 22.6, 25.3, 23.7, 1, 23.3, 23.9, 16.2, 23.0, 21.6, 10.8, 12.2, 23.6, 10.1, 24.4, 16.4, 11.7, 17.7, 34.3, 24.3, 18.7, 27.5, 25.8, 22.5, 14.2, 21.7, 1, 31.2, 13.8, 29.7, 23.1, 26.1, 25.1, 23.4, 21.7, 24.4, 13.2, 22.1, 26.7, 22.7, 1, 18.2, 28.7, 29.1, 27.4, 22.3, 13.2, 22.5, 25.0, 1, 6.6, 23.7, 23.5, 17.3, 24.6, 27.8, 29.7, 25.3, 19.9, 18.2, 26.2, 20.4, 23.3, 26.7, 26.0, 1, 25.1, 33.1, 35.0, 25.3, 23.6, 23.2, 20.2, 24.7, 22.6, 39.1, 26.5, 22.7];

% Test K-S dla Delikates
% Obliczenie parametrów rozkładu normalnego
mu_delikates = mean(delikates);
sigma_delikates = std(delikates);
% Tworzenie dystrybuanty dla porównania z teoretycznym rozkładem normalnym
CDF_delikates = normcdf(sort(delikates), mu_delikates, sigma_delikates);
[h_ks_del, p_ks_del, ksstat_del] = kstest(delikates, [sort(delikates)', CDF_delikates'], 0.05);
fprintf('Test K-S dla normalności Delikates: h = %d, p = %.4f\n', h_ks_del, p_ks_del);

% Test K-S dla Renety
% Obliczenie parametrów rozkładu normalnego
mu_renety = mean(renety);
sigma_renety = std(renety);
% Tworzenie dystrybuanty dla porównania z teoretycznym rozkładem normalnym
CDF_renety = normcdf(sort(renety), mu_renety, sigma_renety);
[h_ks_ren, p_ks_ren, ksstat_ren] = kstest(renety, [sort(renety)', CDF_renety'], 0.05);
fprintf('Test K-S dla normalności Renety: h = %d, p = %.4f\n', h_ks_ren, p_ks_ren);

% T-test (jak poprzednio)
[h_ttest, p_ttest] = ttest2(delikates, renety);
fprintf('T-test dla porównania Delikates i Renety: h = %d, p = %.4f\n', h_ttest, p_ttest);

% Wykres dystrybuant (jak poprzednio)
n_delikates = length(delikates);
x_delikates = sort(delikates);
y_delikates = (1:n_delikates) / n_delikates;

n_renety = length(renety);
x_renety = sort(renety);
y_renety = (1:n_renety) / n_renety;

figure;
plot(x_delikates, y_delikates, 'bo-', x_renety, y_renety, 'ro-');
title('Empiryczne dystrybuanty dla czasu przebywania pszczół');
xlabel('Czas [s]');
ylabel('Dystrybuanta F(x)');
legend('Delikates', 'Renety');
grid on;

% Test K-S dla porównania obu rozkładów (jak poprzednio)
[h_ks, p_ks, ksstat] = kstest2(delikates, renety);
fprintf('Test K-S dla porównania Delikates i Renety: h = %d, p = %.4f\n', h_ks, p_ks);

% Dodane wykresy QQ dla wizualnej oceny normalności
figure;
subplot(2, 1, 1);
qqplot(delikates);
title('Wykres QQ dla Delikates');

subplot(2, 1, 2);
qqplot(renety);
title('Wykres QQ dla Renety');

% Analiza normalności pokazuje, że dane mogą nie pochodzić z rozkładu
% normalnego, zatem wyniki t-testu należy interpretować z ostrożnością. W
% przypadku znaczącego odchylenia od normalności należy wykorzystać test
% nieparametryczny