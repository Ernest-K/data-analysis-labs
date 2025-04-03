clc, clear, close all

% Dane
data17 = [172.72,157.48,170.18,172.72,175.26,170.18,154.94,149.86,157.48,...
          154.94,175.26,167.64,157.48,157.48,154.94,177.8];

% test normalności
[h1, p1] = swtest(data17, 0.05);
fprintf("SW test: h = %d, p = %.4f\n", h1, p1);

if h1 == 0
    fprintf('Rozkład wyników jest zbliżony do rozkładu normalnego\n');
else
    fprintf('Rozkład wyników NIE jest zbliżony do rozkładu normalnego\n');
end