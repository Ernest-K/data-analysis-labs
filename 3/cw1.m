clc, clear, close all

controlB = [0.08, 0.10, 0.15, 0.17, 0.24, 0.34, 0.38, 0.42, 0.49, 0.50, 0.70, 0.94, 0.95, 1.26, 1.37, 1.55, 1.75, 3.20, 6.98, 50.57];

%n = length(controlB);
%x = sort(controlB);
%y = (1:n) / n;

%figure;
%plot(x, y, 'o-');
%title('Dystrybuanta dla zbioru controlB');
%xlabel('Wartość');
%ylabel('Dystrybuanta F(x)');
%grid on;

cdfplot(controlB)