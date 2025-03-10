clc, clear, close all

data_iris = readtable('iris.txt');
data_glass = readtable('glass.txt');

SL = data_iris.SL;
SW = data_iris.SW;
PL = data_iris.PL;
PW = data_iris.PW;

l_p = 10;

figure
subplot(2,2,1); 
histogram(SL, l_p);
title('Histogram dla SL');

subplot(2,2,2); 
histogram(SW, l_p);
title('Histogram dla SW');

subplot(2,2,3);
histogram(PL, l_p);
title('Histogram dla PL');

subplot(2,2,4);
histogram(PW, l_p);
title('Histogram dla PW');


RI = data_glass.RI;
Na = data_glass.Na;

figure;
subplot(2,1,1);
histogram(RI, l_p);
title('Histogram dla RI');
subplot(2,1,2);
histogram(Na, l_p);
title('Histogram dla Na');