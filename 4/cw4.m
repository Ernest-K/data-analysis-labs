clc, clear, close all

dane = readtable('dane/absolwenci.csv');

% Test dla prób zależnych wymaga, aby dane były sparowane (te same osoby przed i po)
% Jeśli dane zawierają informacje o zarobkach tych samych osób w różnych momentach,
% można przeprowadzić test dla prób zależnych

kobiety = dane.SALARY(strcmp(dane.GENDER, 'Kobieta'));
mezczyzni = dane.SALARY(strcmp(dane.GENDER, 'Mezczyzna'));

% Jeśli dane nie są sparowane, nie można przeprowadzić testu dla prób zależnych
% W tym przypadku można by zastosować test dla prób niezależnych