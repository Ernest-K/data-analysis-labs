clc, clear, close all

n = 300;

data = randn(n, 1);
data1 = gen1(1, n);
data2 = gen2(1, n);
data3 = gen3(1, n);

subplot(411)
histogram(data, 'Normalization', 'pdf')
subplot(412)
histogram(data1, 'Normalization', 'pdf')
subplot(413)
histogram(data2, 'Normalization', 'pdf')
subplot(414)
histogram(data3, 'Normalization', 'pdf')

data_mean = mean(data)
data1_mean = mean(data1)
data2_mean = mean(data2)
data3_mean = mean(data3)

data_var = var(data)
data1_var = var(data1)
data2_var = var(data2)
data3_var = var(data3)