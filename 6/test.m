% Define data for toxic substances and plants
data = [
    % T1
    4.64 5.12 4.64; 5.92 6.10 4.32; 5.25 4.85 4.13; 6.17 4.72 5.17; 
    4.20 5.36 3.77; 5.90 5.41 3.85; 5.07 5.31 4.12; 4.13 4.78 5.07;
    4.07 5.08 3.25; 5.30 4.97 3.49; 4.37 5.85 3.65; 3.76 5.26 4.10;
    % T2
    3.21 3.92 4.95; 3.17 3.75 5.22; 3.88 4.01 5.16; 3.50 4.64 5.35;
    2.47 3.63 4.35; 4.12 3.46 4.89; 3.51 4.01 5.61; 3.85 3.39 4.98;
    4.22 3.78 5.77; 3.07 3.51 5.23; 3.62 3.19 4.76; 2.95 4.04 5.15;
    % T3
    3.75 2.95 2.95; 2.50 3.21 2.80; 2.65 3.15 3.63; 2.84 3.25 3.85;
    3.09 2.30 2.19; 2.90 2.76 3.32; 2.62 3.01 2.68; 2.75 2.31 3.35;
    3.10 2.50 3.12; 1.99 2.02 4.11; 2.42 2.64 2.90; 2.37 2.27 2.75
];

% Reshape data for analysis
% Each substance has 12 measurements for each plant
% We need to create factors for substance and plant
n = 12; % number of measurements per combination
substance_factor = [];
plant_factor = [];
FEV = [];

for i = 1:3 % Loop through substances T1, T2, T3
    for j = 1:3 % Loop through plants Z1, Z2, Z3
        % Extract data for this substance-plant combination
        row_start = (i-1) * n + 1;
        row_end = i * n;
        col = j;
        
        % Get the FEV values for this combination
        values = data(row_start:row_end, col);
        
        % Add to our vectors
        FEV = [FEV; values];
        substance_factor = [substance_factor; repmat(i, n, 1)];
        plant_factor = [plant_factor; repmat(j, n, 1)];
    end
end

% Check assumptions
% 1. Check for normality
figure;
subplot(2,1,1);
qqplot(FEV);
title('Q-Q Plot for All FEV Data');

% 2. Check for equal variances
subplot(2,1,2);
boxplot(FEV, {substance_factor, plant_factor});
title('Boxplot of FEV by Substance and Plant');
xlabel('Substance-Plant Combination');
ylabel('FEV');

% Formal test for equal variances
groups = 10*substance_factor + plant_factor; % Create a unique group id
[p_var, stats_var] = vartestn(FEV, groups, 'Display', 'on');
fprintf('Test for equal variances p-value: %.4f\n', p_var);

% Perform two-way ANOVA
[p, tbl, stats] = anovan(FEV, {substance_factor, plant_factor}, ...
                           'model','interaction', ...
                           'varnames',{'Substance','Plant'});

% Display ANOVA results
fprintf('\nTwo-way ANOVA p-values:\n');
fprintf('Substance factor: %.4f\n', p(1));
fprintf('Plant factor: %.4f\n', p(2));
fprintf('Interaction: %.4f\n', p(3));

% Post-hoc analysis
figure;
[c_substance, m_substance] = multcompare(stats, 'Dimension', 1, 'Display', 'on');
title('Multiple Comparison of Substance Means');

figure;
[c_plant, m_plant] = multcompare(stats, 'Dimension', 2, 'Display', 'on');
title('Multiple Comparison of Plant Means');

% Print results of multiple comparisons for substances
fprintf('\nMultiple comparison results for Substances:\n');
fprintf('Subst 1\tSubst 2\tLower CI\tDiff\tUpper CI\tp-value\n');
for i = 1:size(c_substance, 1)
    fprintf('%d\t\t%d\t\t%.4f\t%.4f\t%.4f\t%.4f\n', 
            c_substance(i, 1), c_substance(i, 2), c_substance(i, 3), 
            c_substance(i, 4), c_substance(i, 5), c_substance(i, 6));
end

% Print results of multiple comparisons for plants
fprintf('\nMultiple comparison results for Plants:\n');
fprintf('Plant 1\tPlant 2\tLower CI\tDiff\tUpper CI\tp-value\n');
for i = 1:size(c_plant, 1)
    fprintf('%d\t\t%d\t\t%.4f\t%.4f\t%.4f\t%.4f\n', 
            c_plant(i, 1), c_plant(i, 2), c_plant(i, 3), 
            c_plant(i, 4), c_plant(i, 5), c_plant(i, 6));
end

% Interpret the results
fprintf('\nInterpretation:\n');
if p(1) < 0.05
    fprintf('- Substance factor is significant (p = %.4f)\n', p(1));
    fprintf('  Different toxic substances have significantly different effects on FEV.\n');
    
    % Check which substances differ
    for i = 1:size(c_substance, 1)
        if c_substance(i, 6) < 0.05
            fprintf('  Substance %d and Substance %d have significantly different effects (p = %.4f)\n', 
                    c_substance(i, 1), c_substance(i, 2), c_substance(i, 6));
        end
    end
else
    fprintf('- Substance factor is not significant (p = %.4f)\n', p(1));
    fprintf('  Different toxic substances do not have significantly different effects on FEV.\n');
end

if p(2) < 0.05
    fprintf('- Plant factor is significant (p = %.4f)\n', p(2));
    fprintf('  Different plants have significantly different effects on FEV.\n');
    
    % Check which plants differ
    for i = 1:size(c_plant, 1)
        if c_plant(i, 6) < 0.05
            fprintf('  Plant %d and Plant %d have significantly different effects (p = %.4f)\n', 
                    c_plant(i, 1), c_plant(i, 2), c_plant(i, 6));
        end
    end
else
    fprintf('- Plant factor is not significant (p = %.4f)\n', p(2));
    fprintf('  Different plants do not have significantly different effects on FEV.\n');
end

if p(3) < 0.05
    fprintf('- Interaction between Substance and Plant is significant (p = %.4f)\n', p(3));
    fprintf('  This indicates that the effect of toxic substances on FEV depends on the plant.\n');
else
    fprintf('- Interaction between Substance and Plant is not significant (p = %.4f)\n', p(3));
    fprintf('  This indicates that the effects of toxic substances and plants on FEV are independent.\n');
end

% Visualize interactions
figure;
interaction_plot = reshape(mean(reshape(FEV, n, 9)), 3, 3)';
plot(1:3, interaction_plot, '-o', 'LineWidth', 2);
title('Interaction Plot: Mean FEV by Substance and Plant');
xlabel('Substance (1=T1, 2=T2, 3=T3)');
ylabel('Mean FEV');
legend('Plant Z1', 'Plant Z2', 'Plant Z3', 'Location', 'best');
grid on;]