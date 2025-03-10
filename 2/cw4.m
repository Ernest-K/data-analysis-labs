clc, clear

n = 25;
x_mean = 3620;
s1 = 90;
s2 = 96;
alpha1 = 0.05;
alpha2 = 0.1;
x = normrnd(x_mean, s1, [n, 1]);

% Test1
% H0: s = 90
% H1: s != 90
% alpha = 0.05
[h, p] = vartest(x, s1^2, 'Alpha', alpha1)

% Test2
% H0: s >= 96
% H1: s < 96
% alpha = 0.05
[h, p] = vartest(x, s2^2, 'Alpha', alpha1, 'Tail', 'left')

% Test3
% H0: s >= 96
% H1: s < 96
% alpha = 0.1
[h, p] = vartest(x, s2^2, 'Alpha', alpha2, 'Tail', 'left')