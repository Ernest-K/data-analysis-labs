clc, clear, close all

% 1. WCZYTANIE DANYCH
fileName = 'co2.csv';
opts = detectImportOptions(fileName);
dataTable = readtable(fileName, opts);
disp(['Rozmiar tabeli: ', num2str(size(dataTable,1)), ' wierszy x ', num2str(size(dataTable,2)), ' kolumn.']);

makeColumnName = 'Make'; 
co2ColumnName = 'CO2Emissions_g_km_';

selectedMakes = ["TOYOTA", "NISSAN", "HONDA"]; 

co2DataByMake = struct(); 

disp('Filtrowanie danych dla wybranych marek');
for i = 1:length(selectedMakes)
    currentMake = selectedMakes(i);
    
    fieldName = char(currentMake);
    
    isCurrentMake = (dataTable.(makeColumnName) == currentMake);
        
    co2DataByMake.(fieldName) = dataTable.(co2ColumnName)(isCurrentMake);
    fprintf('Liczba obserwacji dla %s: %d\n', currentMake, length(co2DataByMake.(fieldName)));
end

% ĆWICZENIE 2

stats_results = table('Size', [length(selectedMakes), 8], ...
                      'VariableTypes', {'string', 'double', 'double', 'double', 'double', 'double', 'double', 'double'}, ...
                      'VariableNames', {'Marka', 'Srednia', 'OdchStd', 'Min', 'Max', 'Mediana', 'Q1_25p', 'Q3_75p'});
stats_results.Marka = selectedMakes';

for i = 1:length(selectedMakes)
    currentMake = selectedMakes(i);
    fieldName = char(currentMake);
    
    dataForBrand = co2DataByMake.(fieldName);
    
    stats_results.Srednia(i) = mean(dataForBrand, 'omitnan');
    stats_results.OdchStd(i) = std(dataForBrand, 'omitnan');
    stats_results.Min(i) = min(dataForBrand);
    stats_results.Max(i) = max(dataForBrand);
    stats_results.Mediana(i) = median(dataForBrand, 'omitnan');
    stats_results.Q1_25p(i) = prctile(dataForBrand, 25);
    stats_results.Q3_75p(i) = prctile(dataForBrand, 75);
end

disp('Ćwiczenie 2: Parametry rozkładu emisji CO2 dla wybranych marek:');
disp(stats_results);

% Box Plot
co2_all_selected = [];
group_labels_for_boxplot = [];

for i = 1:length(selectedMakes)
    currentMake = selectedMakes(i);
    fieldName = char(currentMake);
    dataForBrand = co2DataByMake.(fieldName);
    
    if ~isempty(dataForBrand)
        co2_all_selected = [co2_all_selected; dataForBrand];
        group_labels_for_boxplot = [group_labels_for_boxplot; repmat(currentMake, length(dataForBrand), 1)];
    end
end

figure;
group_labels_categorical_boxplot = categorical(group_labels_for_boxplot, cellstr(selectedMakes), 'Ordinal', false);

boxplot(co2_all_selected, group_labels_categorical_boxplot);
title('Rozkład emisji CO2 (g/km) dla wybranych marek');
ylabel('Emisja CO2 (g/km)');
xlabel('Marka');
grid on;

% ĆWICZENIE 3

% Sprawdzenie normalności 

alpha_normality = 0.05; 

disp('Ćwiczenie 3: Sprawdzanie normalności rozkładu emisji CO2');

marki_do_testu = selectedMakes;
isNormal = struct();

for i = 1:length(marki_do_testu)
    currentMake = marki_do_testu(i);
    fieldName = char(currentMake);
    data = co2DataByMake.(fieldName);
    
    fprintf('\nTest normalności dla marki: %s\n', currentMake);
   
    
    % Test Sharpio-Wilka
    % H0: dane pochodzą z rozkładu normalnego
    % H1: dane nie pochodzą z rozkładu normalnego
    [h_swtest, p_swtest] = swtest(data, alpha_normality);
    fprintf('Test Sharpio-Wilka: p-value = %.4f, H = %d (1=odrzuć H0)\n', p_swtest, h_swtest);
    if h_swtest
        fprintf('Wg testu Sharpio-Wilka, dane dla %s NIE pochodzą z rozkładu normalnego (p < %.2f).\n', currentMake, alpha_normality);
        isNormal.(fieldName) = false;
    else
        fprintf('Wg testu Sharpio-Wilka, brak podstaw do odrzucenia H0 o normalności danych dla %s (p >= %.2f).\n', currentMake, alpha_normality);
        isNormal.(fieldName) = true;
    end
    
    % Wykres Q-Q plot
    figure;
    qqplot(data);
    title(['Q-Q Plot dla emisji CO2 - Marka: ', char(currentMake)]);
    grid on;
end

% Sprawdzenie równości wariancji

alpha_variance = 0.05;

disp('Ćwiczenie 3: Sprawdzanie równości wariancji emisji CO2');

% Test Levene'a
% H0: wariancje są równe we wszystkich grupach
% H1: co najmniej jedna wariancja jest różna

[p_levene, stats_levene] = vartestn(co2_all_selected, group_labels_for_boxplot);
    
fprintf('Test Levene''a: p-value = %.4f\n', p_levene);
if p_levene < alpha_variance
    fprintf('Wg testu Levene''a, ODRZUCAMY H0. Wariancje emisji CO2 NIE są równe między markami (p < %.2f).\n', alpha_variance);
    variance_equal = false;
else
    fprintf('Wg testu Levene''a, BRAK PODSTAW do odrzucenia H0. Wariancje emisji CO2 można uznać za równe (p >= %.2f).\n', alpha_variance);
    variance_equal = true;
end

alpha_main_test = 0.05;

disp('Ćwiczenie 3: Test Kruskala-Wallisa');

% Usunięcie NaN z danych, jeśli jeszcze jakieś pozostały (kruskalwallis ich nie lubi)
% Tworzymy tabelę tymczasową, żeby łatwo usunąć całe wiersze z NaN w danych CO2
temp_table_for_kw = table(co2_all_selected, group_labels_for_boxplot, 'VariableNames', {'CO2', 'Group'});
temp_table_for_kw = rmmissing(temp_table_for_kw, 'DataVariables', 'CO2');

if height(temp_table_for_kw) < 3 || length(unique(temp_table_for_kw.Group)) < 2
    disp('Za mało danych lub grup po usunięciu NaN do przeprowadzenia testu Kruskala-Wallisa.');
else
    % Test Kruskala-Wallisa
    % H0: wszystkie próbki pochodzą z populacji o tej samej medianie
    % H1: co najmniej jedna próbka pochodzi z populacji o innej medianie
    [p_kw, tbl_kw, stats_kw] = kruskalwallis(temp_table_for_kw.CO2, temp_table_for_kw.Group, 'off');

    fprintf('Test Kruskala-Wallisa:\n');
    fprintf('  Chi-kwadrat (przybliżony) = %.4f\n', tbl_kw{2,5}); % Wartość statystyki testowej
    fprintf('  Stopnie swobody (df) = %d\n', tbl_kw{2,3});
    fprintf('  p-value = %.4f\n', p_kw);

    if p_kw < alpha_main_test
        fprintf('Wniosek: ODRZUCAMY H0. Istnieją statystycznie istotne różnice w medianach emisji CO2 między markami (p < %.2f).\n', alpha_main_test);
        kruskal_wallis_significant = true;
    else
        fprintf('Wniosek: BRAK PODSTAW do odrzucenia H0. Nie stwierdzono statystycznie istotnych różnic w medianach emisji CO2 między markami (p >= %.2f).\n', alpha_main_test);
        kruskal_wallis_significant = false;
    end
    
    % Wyświetlenie tabeli wyników z funkcji kruskalwallis (jeśli potrzebne)
    disp('Tabela wyników testu Kruskala-Wallisa:');
    disp(cell2table(tbl_kw(2:end,:), 'VariableNames', tbl_kw(1,:))); % tbl_kw zawiera też nagłówki
    
end

disp('Ćwiczenie 3: Analiza post-hoc po teście Kruskala-Wallisa');

if exist('kruskal_wallis_significant', 'var') && kruskal_wallis_significant
    fprintf('Test Kruskala-Wallisa był istotny, dlatego przeprowadzamy analizę post-hoc.\n');

    figure;
    comparison_table = multcompare(stats_kw);

    disp(array2table(comparison_table, 'VariableNames', {'GrupaA', 'GrupaB', 'DolnyCI', 'Różnica', 'GórnyCI', 'p-value'}));
else
    fprintf('Test Kruskala-Wallisa nie był istotny, analiza post-hoc nie jest konieczna.\n');
end

alpha_pairwise = 0.05; % Poziom istotności dla testów parami

disp('Ćwiczenie 4: Testy parami (U Manna-Whitneya)');

% Pobranie danych dla każdej marki (bez NaN)
toyota_data_clean = co2DataByMake.TOYOTA(~isnan(co2DataByMake.TOYOTA));
nissan_data_clean = co2DataByMake.NISSAN(~isnan(co2DataByMake.NISSAN));
honda_data_clean = co2DataByMake.HONDA(~isnan(co2DataByMake.HONDA));

% 1. Porównanie: Toyota vs Nissan
[p_toyota_nissan, h_toyota_nissan, stats_tn] = ranksum(toyota_data_clean, nissan_data_clean, 'alpha', alpha_pairwise);
fprintf('Test U Manna-Whitneya (ranksum): p-value = %.4f, H = %d (1=odrzuć H0)\n', p_toyota_nissan, h_toyota_nissan);
if h_toyota_nissan
    fprintf('Wniosek: Istnieje statystycznie istotna różnica w rozkładach emisji CO2 między Toyotą a Nissanem (p < %.2f).\n', alpha_pairwise);
else
    fprintf('Wniosek: Brak podstaw do stwierdzenia istotnej różnicy w rozkładach emisji CO2 między Toyotą a Nissanem (p >= %.2f).\n', alpha_pairwise);
end

% 2. Porównanie: Toyota vs Honda
[p_toyota_honda, h_toyota_honda, stats_th] = ranksum(toyota_data_clean, honda_data_clean, 'alpha', alpha_pairwise);
fprintf('Test U Manna-Whitneya (ranksum): p-value = %.4f, H = %d (1=odrzuć H0)\n', p_toyota_honda, h_toyota_honda);
if h_toyota_honda
    fprintf('Wniosek: Istnieje statystycznie istotna różnica w rozkładach emisji CO2 między Toyotą a Hondą (p < %.2f).\n', alpha_pairwise);
else
    fprintf('Wniosek: Brak podstaw do stwierdzenia istotnej różnicy w rozkładach emisji CO2 między Toyotą a Hondą (p >= %.2f).\n', alpha_pairwise);
end

% 3. Porównanie: Nissan vs Honda
[p_nissan_honda, h_nissan_honda, stats_nh] = ranksum(nissan_data_clean, honda_data_clean, 'alpha', alpha_pairwise);
fprintf('Test U Manna-Whitneya (ranksum): p-value = %.4f, H = %d (1=odrzuć H0)\n', p_nissan_honda, h_nissan_honda);
if h_nissan_honda
    fprintf('Wniosek: Istnieje statystycznie istotna różnica w rozkładach emisji CO2 między Nissanem a Hondą (p < %.2f).\n', alpha_pairwise);
else stats_results
    fprintf('Wniosek: Brak podstaw do stwierdzenia istotnej różnicy w rozkładach emisji CO2 między Nissanem a Hondą (p >= %.2f).\n', alpha_pairwise);
end

alpha_one_sample_test = 0.05; % Poziom istotności

disp('Ćwiczenie 5: Testowanie mediany vs wartość progowa (Mediana + 10%)');

for i = 1:length(selectedMakes)
    currentMake = selectedMakes(i);
    fieldName = char(currentMake);
    data_clean = co2DataByMake.(fieldName)(~isnan(co2DataByMake.(fieldName)));
    
    idx_marki_w_stats = find(strcmp(stats_results.Marka, currentMake));
    mediana_z_cw2 = stats_results.Mediana(idx_marki_w_stats);
    
    % Obliczenie wartości progowej
    wartosc_progowa = mediana_z_cw2 + 0.10 * mediana_z_cw2;
    
    fprintf('\nAnaliza dla marki: %s\n', currentMake);
    fprintf('Mediana z Ćwiczenia 2: %.2f g/km\n', mediana_z_cw2);
    fprintf('Wartość progowa (Mediana + 10%%): %.2f g/km\n', wartosc_progowa);
    
    % Test znaków Wilcoxona dla jednej próby (signrank)
    % H0: mediana = wartosc_progowa
    % H1: mediana < wartosc_progowa
    [p_signrank, h_signrank, stats_sr] = signrank(data_clean, wartosc_progowa, ...
                                                     'alpha', alpha_one_sample_test, ...
                                                     'tail', 'left');
                                                 
    fprintf('Test znaków Wilcoxona (vs %.2f g/km):\n', wartosc_progowa);
    fprintf('  p-value = %.4f, H = %d (1=odrzuć H0)\n', p_signrank, h_signrank);
    
    if h_signrank
        fprintf('  Wniosek: ODRZUCAMY H0. Mediana emisji CO2 dla %s (%.2f) jest statystycznie istotnie MNIEJSZA niż wartość progowa (%.2f g/km).\n', ...
            currentMake, median(data_clean), wartosc_progowa);
    else
        fprintf('  Wniosek: BRAK PODSTAW do odrzucenia H0. Nie ma dowodów, że mediana emisji CO2 dla %s (%.2f) jest mniejsza niż wartość progowa (%.2f g/km).\n', ...
            currentMake, median(data_clean), wartosc_progowa);
    end
end