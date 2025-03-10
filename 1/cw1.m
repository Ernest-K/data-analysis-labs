clc; % Wyczyść ekran
clear; % Wyczyść zmienne

a = 1;
who % Spis dostępnych zmiennych

Z = zeros(3,3) % Macierz 3x3 wypełniona zerami
O = ones(3,3)  % Macierz 3x3 wypełniona jedynkami
I = eye(3)     % Macierz jednostkowa 3x3

a = [1, 2; 3, 4];
R = repmat(a, 2, 2) % Tworzy macierz 4x4 składającą się z powielonych bloków a

randMatrix = rand(3,3)   % Macierz 3x3 wypełniona liczbami z rozkładu jednostajnego (0,1)
randnMatrix = randn(3,3) % Macierz 3x3 wypełniona liczbami z rozkładu normalnego (średnia=0, wariancja=1)

sizeO = size(O)      % Rozmiar macierzy ones
lengthO = length(O)  % Długość największego wymiaru macierzy ones

A = [1,2,3,4;5,6,7,8;9,1,2,3]

A_transposed = A' % Transpozycja macierzy

B = [1,2;3,4];
add_AB = A(1:2,1:2) + B % Dodawanie macierzy (dla zgodnych rozmiarów)
sub_AB = A(1:2,1:2) - B % Odejmowanie macierzy
mul_AB = A(1:2,1:2) * B % Mnożenie macierzy (macierzowe)
elem_mul_AB = A(1:2,1:2) .* B % Mnożenie element po elemencie

B_elem = B(1,2) % Element z pierwszego wiersza, drugiej kolumny
