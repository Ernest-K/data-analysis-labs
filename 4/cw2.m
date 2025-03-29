clc, clear, close all

nerwowi  = [3, 3, 4, 5, 5];
spokojni = [4, 6, 7, 9, 9];

% testy normalności
disp("SW testy nerwowych, spokojnych")
[hn, pn] = swtest(nerwowi, 0.05);
fprintf("Nerwowi: h = %d, p = %.4f\n", hn, pn);
[hs, ps] = swtest(spokojni, 0.05);
fprintf("Spokojni: h = %d, p = %.4f\n", hs, ps);

% test na równość wariancji
disp("F-test")
[hf, pf, cif, f] = vartest2(nerwowi, spokojni);
fprintf("h = %d, p = %.4f\n", hf, pf);

% t test
% H0: Osoby nerwowe gestykulują mniej (μ_s > μ_n)
% H1: Osoby nerwowe gestykulują więcej (μ_s < μ_n)
disp("t-test")
[h, p, ci, s] = ttest2(nerwowi,spokojni,'tail','left');
fprintf("h = %d, p = %.4f\n", h, p);
fprintf("t(%.0f) = %.4f, SD_n = %.4f", s.df, s.tstat, s.sd(1));

% hipoteza alternatywna to to, ze nerwowi wykonuja wiecej gestow