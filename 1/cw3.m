clc, clear, close all

data = randn(300, 1);

subplot(411)
plot(data)
subplot(412)
histogram(data, 20)
subplot(413)
histogram(data, 100)
subplot(414)
boxplot(data)
