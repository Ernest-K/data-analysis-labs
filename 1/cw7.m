clc, clear

% Obliczanie P(Z < 2) dla rozkładu N(0,1)
P_Z_less_2 = normcdf(2, 0, 1); % Odczytanie z dystrybuanty rozkładu normalnego

% Obliczanie P(|Z| < 2) dla rozkładu N(0,1)
P_Z_less_minus_2 = normcdf(-2, 0, 1);  % P(Z < -2)
P_abs_Z_less_2 = P_Z_less_2 - P_Z_less_minus_2;

fprintf('P(Z < 2) = %.4f\n', P_Z_less_2);
fprintf('P(|Z| < 2) = %.4f\n', P_abs_Z_less_2);