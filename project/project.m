clc, clear, close all

% --- POCZĄTEK KODU DO URUCHOMIENIA ---

% 1. WCZYTANIE DANYCH (zakładam, że już to masz, ale dla kompletności)
fileName = 'co2.csv';
opts = detectImportOptions(fileName);
dataTable = readtable(fileName, opts);
disp('Dane zostały wczytane.');
disp(['Rozmiar tabeli: ', num2str(size(dataTable,1)), ' wierszy x ', num2str(size(dataTable,2)), ' kolumn.']);

% 2. DEFINICJA NAZW KOLUMN I MAREK
% !!! ZASTĄP PONIŻSZE NAZWY RZECZYWISTYMI NAZWAMI KOLUMN Z TWOJEJ TABELI !!!
makeColumnName = 'Make'; % Przykładowa, rzeczywista nazwa kolumny z marką
co2ColumnName = 'CO2Emissions_g_km_'; % Przykładowa, rzeczywista nazwa kolumny z CO2

selectedMakes = ["TOYOTA", "NISSAN", "HONDA"]; % Używamy string array

% 3. FILTROWANIE DANYCH I PRZECHOWYWANIE W STRUKTURZE
% Użyjemy struktury do przechowywania danych CO2 dla każdej marki
co2DataByMake = struct(); 

disp('Filtrowanie danych dla wybranych marek...');
for i = 1:length(selectedMakes)
    currentMake = selectedMakes(i);
    
    % Tworzenie poprawnej nazwy pola w strukturze (bez spacji, znaków specjalnych)
    % MATLAB automatycznie to robi, ale lepiej być pewnym.
    % Jeśli nazwy marek są proste (jak tutaj), to currentMake jest OK.
    fieldName = char(currentMake); % Konwersja na char array dla nazwy pola
    
    try
        % Założenie: makeColumnName zawiera dane typu string
        isCurrentMake = (dataTable.(makeColumnName) == currentMake);
        
        co2DataByMake.(fieldName) = dataTable.(co2ColumnName)(isCurrentMake);
        fprintf('Liczba obserwacji dla %s: %d\n', currentMake, length(co2DataByMake.(fieldName)));
        
        if isempty(co2DataByMake.(fieldName))
            warning('Brak danych dla %s. Sprawdź nazwę marki i dane.', currentMake);
        end
    catch ME
        fprintf('Błąd przy filtrowaniu danych dla %s:\n', currentMake);
        disp(ME.message);
        co2DataByMake.(fieldName) = [];
    end
end

% Wyświetl kilka pierwszych wartości dla każdej marki, aby sprawdzić
if isfield(co2DataByMake, 'TOYOTA') && ~isempty(co2DataByMake.TOYOTA)
    disp('Pierwsze kilka wartości CO2 dla Toyoty:'); disp(head(co2DataByMake.TOYOTA));
end
if isfield(co2DataByMake, 'NISSAN') && ~isempty(co2DataByMake.NISSAN)
    disp('Pierwsze kilka wartości CO2 dla Nissana:'); disp(head(co2DataByMake.NISSAN));
end
if isfield(co2DataByMake, 'HONDA') && ~isempty(co2DataByMake.HONDA)
    disp('Pierwsze kilka wartości CO2 dla Hondy:'); disp(head(co2DataByMake.HONDA));
end

% --- KONIEC KODU PRZYGOTOWANIA DANYCH ---

% --- POCZĄTEK KODU ĆWICZENIA 2 (uruchom po powyższym bloku) ---

% Sprawdzenie, czy struktura z danymi istnieje i ma pola
if ~exist('co2DataByMake', 'var') || ~all(isfield(co2DataByMake, cellstr(selectedMakes)))
    error('Struktura co2DataByMake nie została poprawnie utworzona lub brakuje danych dla wybranych marek.');
end

% Przygotowanie tabeli do przechowywania wyników
stats_results = table('Size', [length(selectedMakes), 8], ...
                      'VariableTypes', {'string', 'double', 'double', 'double', 'double', 'double', 'double', 'double'}, ...
                      'VariableNames', {'Marka', 'Srednia', 'OdchStd', 'Min', 'Max', 'Mediana', 'Q1_25p', 'Q3_75p'});
stats_results.Marka = selectedMakes'; % Transpozycja, aby pasowało do tabeli

% Pętla do obliczania statystyk dla każdej marki
disp('Obliczanie parametrów rozkładu...');
for i = 1:length(selectedMakes)
    currentMake = selectedMakes(i);
    fieldName = char(currentMake);
    
    dataForBrand = co2DataByMake.(fieldName);
    
    if isempty(dataForBrand)
        fprintf('Brak danych dla %s, pomijanie obliczeń statystyk.\n', currentMake);
        stats_results(i, 2:end) = {NaN}; % Wypełnij wiersz NaN-ami
        continue; % Przejdź do następnej marki
    end
    
    stats_results.Srednia(i) = mean(dataForBrand, 'omitnan');
    stats_results.OdchStd(i) = std(dataForBrand, 'omitnan');
    stats_results.Min(i) = min(dataForBrand);
    stats_results.Max(i) = max(dataForBrand);
    stats_results.Mediana(i) = median(dataForBrand, 'omitnan');
    stats_results.Q1_25p(i) = prctile(dataForBrand, 25);
    stats_results.Q3_75p(i) = prctile(dataForBrand, 75);
end

% Wyświetl wyniki
disp('Ćwiczenie 2: Parametry rozkładu emisji CO2 dla wybranych marek:');
disp(stats_results);

% WIZUALIZACJA - Wykres pudełkowy (Box Plot)
% Przygotowanie danych do boxplota
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

if ~isempty(co2_all_selected)
    figure; % Stwórz nowe okno wykresu
    % Konwersja etykiet na kategoryczne dla poprawnego sortowania i wyglądu na osi
    group_labels_categorical_boxplot = categorical(group_labels_for_boxplot, cellstr(selectedMakes), 'Ordinal', false);
    
    boxplot(co2_all_selected, group_labels_categorical_boxplot);
    title('Rozkład emisji CO2 (g/km) dla wybranych marek');
    ylabel('Emisja CO2 (g/km)');
    xlabel('Marka');
    grid on;
else
    disp('Brak danych do wygenerowania wykresu pudełkowego.');
end

% --- KONIEC KODU ĆWICZENIA 2 ---


% --- POCZĄTEK KODU ĆWICZENIA 3 - KROK 3.1 (Sprawdzenie normalności) ---
% Zakładamy, że masz już wektory: co2DataByMake.TOYOTA, co2DataByMake.NISSAN, co2DataByMake.HONDA

alpha_normality = 0.05; % Poziom istotności dla testów normalności

disp('--- Ćwiczenie 3: Sprawdzanie normalności rozkładu emisji CO2 ---');

marki_do_testu = selectedMakes; % Z poprzedniego kroku ["TOYOTA", "NISSAN", "HONDA"]
isNormal = struct();

for i = 1:length(marki_do_testu)
    currentMake = marki_do_testu(i);
    fieldName = char(currentMake);
    data = co2DataByMake.(fieldName);
    
    fprintf('\nTest normalności dla marki: %s\n', currentMake);
    
    % Usunięcie NaN, jeśli istnieją, bo testy normalności ich nie obsługują
    data_no_nan = data(~isnan(data));
    if length(data_no_nan) < 3 % Testy normalności wymagają min. liczby obserwacji
        fprintf('Za mało danych (po usunięciu NaN) do przeprowadzenia testu normalności dla %s.\n', currentMake);
        isNormal.(fieldName) = NaN; % lub false, w zależności jak chcesz to oznaczyć
        continue;
    end
    
    % Test Lillieforsa (alternatywa dla Shapiro-Wilka w podstawowym MATLABie)
    % H0: dane pochodzą z rozkładu normalnego
    % H1: dane nie pochodzą z rozkładu normalnego
    [h_lillie, p_lillie] = swtest(data_no_nan, alpha_normality);
    fprintf('Test Lillieforsa: p-value = %.4f, H = %d (1=odrzuć H0)\n', p_lillie, h_lillie);
    if h_lillie
        fprintf('Wg testu Lillieforsa, dane dla %s NIE pochodzą z rozkładu normalnego (p < %.2f).\n', currentMake, alpha_normality);
        isNormal.(fieldName) = false;
    else
        fprintf('Wg testu Lillieforsa, brak podstaw do odrzucenia H0 o normalności danych dla %s (p >= %.2f).\n', currentMake, alpha_normality);
        isNormal.(fieldName) = true;
    end
    
    % Wykres Q-Q plot
    figure;
    qqplot(data_no_nan);
    title(['Q-Q Plot dla emisji CO2 - Marka: ', char(currentMake)]);
    grid on;
end

disp(isNormal);
% --- KONIEC KODU KROKU 3.1 ---

% KROK 3.1b (Sprawdzenie równości wariancji) ---
% Zakładamy, że masz już wektory: co2DataByMake.TOYOTA, co2DataByMake.NISSAN, co2DataByMake.HONDA
% oraz przygotowane dane do boxplota z poprzedniego kroku (co2_all_selected i group_labels_for_boxplot)

alpha_variance = 0.05; % Poziom istotności dla testu równości wariancji

disp('--- Ćwiczenie 3: Sprawdzanie równości wariancji emisji CO2 ---');

% Przygotowanie danych do testu Levene'a (vartestn wymaga jednego wektora danych i jednego wektora grup)
% Użyjemy danych przygotowanych wcześniej do boxplota:
% co2_all_selected
% group_labels_for_boxplot (lub group_labels_categorical_boxplot)

if isempty(co2_all_selected) || isempty(group_labels_for_boxplot)
    error('Dane do testu równości wariancji nie są przygotowane. Uruchom poprzednie bloki.');
end

% Test Levene'a (funkcja vartestn z opcją 'TestType','LeveneAbsolute' lub 'LeveneQuadratic')
% H0: wariancje są równe we wszystkich grupach
% H1: co najmniej jedna wariancja jest różna
% 'LeveneAbsolute' (oparty na medianie) jest często rekomendowany jako bardziej odporny
try
    [p_levene, stats_levene] = vartestn(co2_all_selected, group_labels_for_boxplot, ...
                                       'TestType', 'LeveneAbsolute', 'Display', 'off');
    % 'Display','off' wyłącza domyślne tworzenie wykresu przez vartestn
    
    fprintf('Test Levene''a (oparty na medianie): p-value = %.4f\n', p_levene);
    if p_levene < alpha_variance
        fprintf('Wg testu Levene''a, ODRZUCAMY H0. Wariancje emisji CO2 NIE są równe między markami (p < %.2f).\n', alpha_variance);
        variance_equal = false;
    else
        fprintf('Wg testu Levene''a, BRAK PODSTAW do odrzucenia H0. Wariancje emisji CO2 można uznać za równe (p >= %.2f).\n', alpha_variance);
        variance_equal = true;
    end
catch ME
    disp('Wystąpił błąd podczas przeprowadzania testu Levene''a:');
    disp(ME.message);
    disp('Możliwe, że funkcja vartestn nie jest dostępna lub wystąpił problem z danymi.');
    disp('Jeśli nie masz Statistics and Machine Learning Toolbox, test Levene''a może nie być dostępny.');
    variance_equal = NaN; % Nie można określić
end

% --- KONIEC KODU KROKU 3.1b ---

% --- POCZĄTEK KODU ĆWICZENIA 3 - KROK 3.2 (Test Kruskala-Wallisa) ---
% Zakładamy, że masz już przygotowane dane:
% co2_all_selected (jeden wektor ze wszystkimi wartościami CO2 dla wybranych marek)
% group_labels_for_boxplot (wektor z etykietami marek odpowiadający każdej wartości CO2)

alpha_main_test = 0.05; % Poziom istotności dla głównego testu

disp('--- Ćwiczenie 3: Test Kruskala-Wallisa ---');

if isempty(co2_all_selected) || isempty(group_labels_for_boxplot)
    error('Dane do testu Kruskala-Wallisa nie są przygotowane. Uruchom poprzednie bloki.');
end

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
    % 'off' wyłącza domyślne tworzenie wykresu i tabeli przez kruskalwallis

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
% --- KONIEC KODU KROKU 3.2 ---
% --- POCZĄTEK KODU ĆWICZENIA 3 - KROK 3.3 (Analiza post-hoc) ---
% Zakładamy, że zmienna 'kruskal_wallis_significant' została ustawiona w poprzednim kroku
% oraz 'stats_kw' zawiera statystyki z funkcji kruskalwallis

disp('--- Ćwiczenie 3: Analiza post-hoc po teście Kruskala-Wallisa ---');

if exist('kruskal_wallis_significant', 'var') && kruskal_wallis_significant
    fprintf('Test Kruskala-Wallisa był istotny, przeprowadzam analizę post-hoc.\n');
    
    % Przeprowadzenie analizy post-hoc za pomocą multcompare
    % 'stats_kw' to struktura zwrócona przez kruskalwallis
    % 'alpha' to poziom istotności dla porównań
    % 'ctype' (critical value type) można ustawić, np. 'tukey-kramer' lub 'dunn-sidak'
    % Domyślnie dla Kruskala-Wallisa, multcompare użyje odpowiednich metod opartych na rangach.
    
    try
        figure; % Stwórz nowe okno dla wykresu z multcompare
        comparison_table = multcompare(stats_kw, 'Alpha', alpha_main_test, 'CType', 'bonferroni', 'Display', 'on');
        % Opcje CType: 'tukey-kramer', 'hsd' (to samo co tukey-kramer), 
        % 'lsd' (least significant difference), 'bonferroni', 'dunn-sidak', 'scheffe'
        % Dla Kruskala-Wallisa, Bonferroni lub Dunn-Sidak są częstymi wyborami.
        % 'Display', 'on' wyświetli tabelę i wykres
        
        % Tabela comparison_table zawiera:
        % Kolumna 1: Indeks grupy 1
        % Kolumna 2: Indeks grupy 2
        % Kolumna 3: Dolna granica przedziału ufności dla różnicy (lub różnicy rang)
        % Kolumna 4: Szacowana różnica (lub różnica średnich rang)
        % Kolumna 5: Górna granica przedziału ufności
        % Kolumna 6: p-value dla porównania tej pary
        
        disp('Wyniki analizy post-hoc (multcompare):');
        % Wyświetlenie tabeli w bardziej czytelny sposób z nazwami grup
        % Nazwy grup są w stats_kw.gnames
        group_names_posthoc = stats_kw.gnames;
        
        fprintf('\nPorównania parami (alpha = %.2f, korekta Bonferroniego):\n', alpha_main_test);
        fprintf('-----------------------------------------------------------------------------------\n');
        fprintf('Grupa 1        Grupa 2        Różnica Śr. Rang   Dolny CI      Górny CI       p-value\n');
        fprintf('-----------------------------------------------------------------------------------\n');
        for i = 1:size(comparison_table, 1)
            idx1 = comparison_table(i,1);
            idx2 = comparison_table(i,2);
            
            % Sprawdzenie czy nazwy grup są dostępne i czy indeksy są poprawne
            name1 = 'Nieznana';
            if idx1 > 0 && idx1 <= length(group_names_posthoc) && ~isempty(group_names_posthoc{idx1})
                name1 = group_names_posthoc{idx1};
            end
            
            name2 = 'Nieznana';
            if idx2 > 0 && idx2 <= length(group_names_posthoc) && ~isempty(group_names_posthoc{idx2})
                name2 = group_names_posthoc{idx2};
            end

            fprintf('%-15s vs %-15s %10.2f      %10.2f    %10.2f    %10.4f', ...
                name1, ...
                name2, ...
                comparison_table(i,4), ... % Różnica średnich rang
                comparison_table(i,3), ... % Dolny CI
                comparison_table(i,5), ... % Górny CI
                comparison_table(i,6));    % p-value
            if comparison_table(i,6) < alpha_main_test
                fprintf('  *\n'); % Oznacz istotne różnice
            else
                fprintf('\n');
            end
        end
        fprintf('-----------------------------------------------------------------------------------\n');
        fprintf('* Oznacza statystycznie istotną różnicę na poziomie p < %.2f\n', alpha_main_test);

    catch ME
        disp('Wystąpił błąd podczas przeprowadzania analizy post-hoc (multcompare):');
        disp(ME.message);
        disp('Upewnij się, że masz Statistics and Machine Learning Toolbox.');
    end
    
else
    fprintf('Test Kruskala-Wallisa nie był istotny, analiza post-hoc nie jest konieczna.\n');
end

% --- KONIEC KODU KROKU 3.3 ---

% --- POCZĄTEK KODU ĆWICZENIA 4 (Testy parami) ---
% Zakładamy, że masz już wektory: co2DataByMake.TOYOTA, co2DataByMake.NISSAN, co2DataByMake.HONDA

alpha_pairwise = 0.05; % Poziom istotności dla testów parami

disp('--- Ćwiczenie 4: Testy parami (U Manna-Whitneya) ---');

% Pobranie danych dla każdej marki (bez NaN)
toyota_data_clean = co2DataByMake.TOYOTA(~isnan(co2DataByMake.TOYOTA));
nissan_data_clean = co2DataByMake.NISSAN(~isnan(co2DataByMake.NISSAN));
honda_data_clean = co2DataByMake.HONDA(~isnan(co2DataByMake.HONDA));

% 1. Porównanie: Toyota vs Nissan
fprintf('\nPorównanie: Toyota vs Nissan\n');
if length(toyota_data_clean) >=1 && length(nissan_data_clean) >=1 % ranksum potrzebuje niepustych wektorów
    [p_toyota_nissan, h_toyota_nissan, stats_tn] = ranksum(toyota_data_clean, nissan_data_clean, 'alpha', alpha_pairwise);
    fprintf('Test U Manna-Whitneya (ranksum): p-value = %.4f, H = %d (1=odrzuć H0)\n', p_toyota_nissan, h_toyota_nissan);
    if h_toyota_nissan
        fprintf('Wniosek: Istnieje statystycznie istotna różnica w rozkładach emisji CO2 między Toyotą a Nissanem (p < %.2f).\n', alpha_pairwise);
    else
        fprintf('Wniosek: Brak podstaw do stwierdzenia istotnej różnicy w rozkładach emisji CO2 między Toyotą a Nissanem (p >= %.2f).\n', alpha_pairwise);
    end
    fprintf('  Mediana Toyota: %.2f, Mediana Nissan: %.2f\n', median(toyota_data_clean), median(nissan_data_clean));
else
    disp('Za mało danych dla Toyoty lub Nissana do przeprowadzenia testu.');
end

% 2. Porównanie: Toyota vs Honda
fprintf('\nPorównanie: Toyota vs Honda\n');
if length(toyota_data_clean) >=1 && length(honda_data_clean) >=1
    [p_toyota_honda, h_toyota_honda, stats_th] = ranksum(toyota_data_clean, honda_data_clean, 'alpha', alpha_pairwise);
    fprintf('Test U Manna-Whitneya (ranksum): p-value = %.4f, H = %d (1=odrzuć H0)\n', p_toyota_honda, h_toyota_honda);
    if h_toyota_honda
        fprintf('Wniosek: Istnieje statystycznie istotna różnica w rozkładach emisji CO2 między Toyotą a Hondą (p < %.2f).\n', alpha_pairwise);
    else
        fprintf('Wniosek: Brak podstaw do stwierdzenia istotnej różnicy w rozkładach emisji CO2 między Toyotą a Hondą (p >= %.2f).\n', alpha_pairwise);
    end
    fprintf('  Mediana Toyota: %.2f, Mediana Honda: %.2f\n', median(toyota_data_clean), median(honda_data_clean));
else
    disp('Za mało danych dla Toyoty lub Hondy do przeprowadzenia testu.');
end

% 3. Porównanie: Nissan vs Honda
fprintf('\nPorównanie: Nissan vs Honda\n');
if length(nissan_data_clean) >=1 && length(honda_data_clean) >=1
    [p_nissan_honda, h_nissan_honda, stats_nh] = ranksum(nissan_data_clean, honda_data_clean, 'alpha', alpha_pairwise);
    fprintf('Test U Manna-Whitneya (ranksum): p-value = %.4f, H = %d (1=odrzuć H0)\n', p_nissan_honda, h_nissan_honda);
    if h_nissan_honda
        fprintf('Wniosek: Istnieje statystycznie istotna różnica w rozkładach emisji CO2 między Nissanem a Hondą (p < %.2f).\n', alpha_pairwise);
    else
        fprintf('Wniosek: Brak podstaw do stwierdzenia istotnej różnicy w rozkładach emisji CO2 między Nissanem a Hondą (p >= %.2f).\n', alpha_pairwise);
    end
    fprintf('  Mediana Nissan: %.2f, Mediana Honda: %.2f\n', median(nissan_data_clean), median(honda_data_clean));
else
    disp('Za mało danych dla Nissana lub Hondy do przeprowadzenia testu.');
end

% --- KONIEC KODU ĆWICZENIA 4 ---

% --- POCZĄTEK KODU ĆWICZENIA 5 ---
% Zakładamy, że masz już wektory: co2DataByMake.TOYOTA, co2DataByMake.NISSAN, co2DataByMake.HONDA
% oraz tabelę stats_results z Ćwiczenia 2

alpha_one_sample_test = 0.05; % Poziom istotności

disp('--- Ćwiczenie 5: Testowanie mediany vs wartość progowa (Mediana + 10%) ---');

marki_do_testu_cw5 = selectedMakes; % ["TOYOTA", "NISSAN", "HONDA"]

for i = 1:length(marki_do_testu_cw5)
    currentMake = marki_do_testu_cw5(i);
    fieldName = char(currentMake);
    data_clean = co2DataByMake.(fieldName)(~isnan(co2DataByMake.(fieldName)));
    
    % Pobranie mediany z Ćwiczenia 2 (z tabeli stats_results)
    % Upewnij się, że kolejność marek w stats_results.Marka jest taka sama jak w selectedMakes
    % lub znajdź wiersz po nazwie marki
    idx_marki_w_stats = find(strcmp(stats_results.Marka, currentMake));
    if isempty(idx_marki_w_stats)
        fprintf('Nie znaleziono statystyk dla marki %s w tabeli stats_results. Pomijam.\n', currentMake);
        continue;
    end
    mediana_z_cw2 = stats_results.Mediana(idx_marki_w_stats);
    
    % Obliczenie wartości progowej
    wartosc_progowa = mediana_z_cw2 + 0.10 * mediana_z_cw2;
    
    fprintf('\n--- Analiza dla marki: %s ---\n', currentMake);
    fprintf('Mediana z Ćwiczenia 2: %.2f g/km\n', mediana_z_cw2);
    fprintf('Wartość progowa (Mediana + 10%%): %.2f g/km\n', wartosc_progowa);
    
    if isempty(data_clean) || length(data_clean) < 2 % signrank potrzebuje danych
        fprintf('Za mało danych dla marki %s do przeprowadzenia testu.\n', currentMake);
        continue;
    end
    
    % Test znaków Wilcoxona dla jednej próby (signrank)
    % H0: mediana(data_clean) = wartosc_progowa
    % H1 (lewostronna, 'tail','left'): mediana(data_clean) < wartosc_progowa
    
    % signrank testuje, czy mediana różnic (data - m0) jest równa zero.
    % Aby przetestować mediana(data) < m0, testujemy czy mediana(data - m0) < 0.
    try
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
        % Wyświetlenie mediany z próby dla porównania
        fprintf('  (Obserwowana mediana w próbie dla %s: %.2f g/km)\n', currentMake, median(data_clean));

    catch ME
        fprintf('Błąd podczas testu signrank dla marki %s: %s\n', currentMake, ME.message);
        fprintf('Możliwe, że wszystkie różnice są zerowe lub za mało danych.\n');
    end
end

% --- KONIEC KODU ĆWICZENIA 5 ---

% --- POCZĄTEK KODU ĆWICZENIA 6 (z CTG dla średniej) ---
% Zakładamy, że masz już wektory: co2DataByMake.TOYOTA, co2DataByMake.NISSAN, co2DataByMake.HONDA
% oraz tabelę stats_results z Ćwiczenia 2

alpha_conf_levels = [0.05, 0.01]; % Dla 95% (1-0.05) i 99% (1-0.01) przedziałów ufności
min_n_for_ctg = 30; % Minimalna liczebność próby, aby powołać się na CTG (można dyskutować)

disp('--- Ćwiczenie 6: Przedziały ufności i wizualizacja ---');

marki_do_analizy_cw6 = selectedMakes; % ["TOYOTA", "NISSAN", "HONDA"]

% Przygotowanie tabel do przechowywania wyników
results_ci_mean_ctg = cell(length(marki_do_analizy_cw6), length(alpha_conf_levels) + 2); % Dodatkowa kolumna na N
results_ci_var_info = cell(length(marki_do_analizy_cw6), 2);

mean_var_names_ctg = {'Marka', 'N'};
var_var_names_info = {'Marka', 'Komentarz_CI_Wariancja'};

for k=1:length(alpha_conf_levels)
    conf_level_percent = (1-alpha_conf_levels(k))*100;
    mean_var_names_ctg{end+1} = sprintf('Srednia_CI_%.0f%%_CTG', conf_level_percent);
end

% Wypełnienie nazw marek w tabelach wynikowych
for i = 1:length(marki_do_analizy_cw6)
    results_ci_mean_ctg{i,1} = char(marki_do_analizy_cw6(i));
    results_ci_var_info{i,1} = char(marki_do_analizy_cw6(i));
end


for i = 1:length(marki_do_analizy_cw6)
    currentMake = marki_do_analizy_cw6(i);
    fieldName = char(currentMake);
    data_clean = co2DataByMake.(fieldName)(~isnan(co2DataByMake.(fieldName)));
    
    n = length(data_clean);
    results_ci_mean_ctg{i,2} = n; % Zapisz liczebność próby
    
    fprintf('\n--- Analiza dla marki: %s (N = %d) ---\n', currentMake, n);
    
    % WIZUALIZACJA: Histogram dla każdej marki
    figure;
    histogram(data_clean, 'Normalization', 'pdf'); % 'pdf' dla gęstości, ułatwia porównanie kształtów
    hold on;
    % Można dodać estymację gęstości jądrowej dla gładszej krzywej
    if n > 1 && license('test', 'Statistics_Toolbox') % ksdensity wymaga toolboxa i min 2 punktów
        pd = fitdist(data_clean,'Kernel','Kernel','normal'); % Używamy jądra normalnego dla ksdensity
        x_values = linspace(min(data_clean),max(data_clean),100);
        y_values = pdf(pd,x_values);
        plot(x_values,y_values,'r-','LineWidth',2);
        legend('Histogram', 'Estymacja gęstości jądrowej');
    else
        legend('Histogram');
    end
    title(['Histogram emisji CO2 dla marki: ', char(currentMake)]);
    xlabel('Emisja CO2 (g/km)');
    ylabel('Gęstość');
    grid on;
    hold off;

    % --- Przedziały ufności dla ŚREDNIEJ (oparte na CTG i rozkładzie t) ---
    fprintf('Przedziały ufności dla ŚREDNIEJ (metoda oparta na CTG/rozkładzie t):\n');
    if n < 2
        fprintf('  Za mało danych (N=%d) do wyznaczenia przedziału ufności dla średniej.\n', n);
        for k=1:length(alpha_conf_levels)
            results_ci_mean_ctg{i,k+2} = 'Za mało danych';
        end
    else
        srednia = mean(data_clean);
        odchStd = std(data_clean);
        se_mean = odchStd / sqrt(n); % Błąd standardowy średniej
        
        if n < min_n_for_ctg
            fprintf('  Uwaga: Liczebność próby N=%d jest mniejsza niż zalecane N=%d dla CTG. Wyniki mogą być mniej wiarygodne.\n', n, min_n_for_ctg);
        end

        for k = 1:length(alpha_conf_levels)
            current_alpha_level = alpha_conf_levels(k);
            conf_level_percent = (1-current_alpha_level)*100;
            
            % Stopnie swobody dla rozkładu t
            df_t = n - 1;
            % Wartość krytyczna t
            t_critical = tinv(1 - current_alpha_level/2, df_t);
            
            % Margines błędu
            margin_of_error = t_critical * se_mean;
            
            % Przedział ufności
            ci_mean_lower = srednia - margin_of_error;
            ci_mean_upper = srednia + margin_of_error;
            
            fprintf('  %.0f%% CI dla średniej: [%.2f, %.2f]\n', conf_level_percent, ci_mean_lower, ci_mean_upper);
            results_ci_mean_ctg{i,k+2} = sprintf('[%.2f, %.2f]', ci_mean_lower, ci_mean_upper);
        end
    end
    
    % --- Przedziały ufności dla WARIANCJI ---
    fprintf('Przedziały ufności dla WARIANCJI:\n');
    komentarz_wariancja = 'Standardowy przedział ufności dla wariancji (oparty na chi-kwadrat) jest niewiarygodny ze względu na brak normalności danych. Zalecana metoda bootstrap (nieużyta w tym podejściu).';
    fprintf('  %s\n', komentarz_wariancja);
    results_ci_var_info{i,2} = komentarz_wariancja;
    
end

% Wyświetlenie sformatowanych tabel
final_table_ci_mean_ctg = cell2table(results_ci_mean_ctg, 'VariableNames', mean_var_names_ctg);
final_table_ci_var_info = cell2table(results_ci_var_info, 'VariableNames', var_var_names_info);

disp(' ');
disp('--- Podsumowanie Ćwiczenia 6 ---');
disp('Przedziały ufności dla ŚREDNIEJ emisji CO2 (g/km) - metoda oparta na CTG/rozkładzie t:');
disp(final_table_ci_mean_ctg);
disp('Informacje o przedziałach ufności dla WARIANCJI emisji CO2 (g/km)^2:');
disp(final_table_ci_var_info);

% Uzasadnienie (dodatkowe)
disp(' ');
disp('Uzasadnienie podejścia do przedziałów ufności:');
disp('Dla średniej: Zastosowano przedział ufności oparty na rozkładzie t-Studenta, powołując się na');
disp('Centralne Twierdzenie Graniczne (CTG), które sugeruje, że rozkład średniej z próby dąży do normalności');
disp('dla odpowiednio dużych prób, nawet jeśli dane źródłowe nie są normalne. Wiarygodność tego podejścia');
disp('rośnie wraz z liczebnością próby. Dla prób o liczebności N < 30, interpretacja może wymagać ostrożności.');
disp('Dla wariancji: Standardowy przedział ufności oparty na rozkładzie chi-kwadrat jest silnie zależny od');
disp('założenia o normalności danych. Ponieważ dane nie spełniają tego założenia, taki przedział byłby');
disp('niewiarygodny. Bardziej odpowiednią metodą byłby bootstrap (jak w poprzedniej propozycji).');

% --- KONIEC KODU ĆWICZENIA 6 ---