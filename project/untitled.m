% --- SKRYPT DO SPRAWDZANIA NORMALNOŚCI DLA WSZYSTKICH MAREK ---
clc, clear, close all

% 1. WCZYTANIE DANYCH
fileName = 'co2.csv'; % Upewnij się, że nazwa pliku jest poprawna
opts = detectImportOptions(fileName);
try
    dataTable = readtable(fileName, opts);
    disp('Dane zostały pomyślnie wczytane.');
catch ME
    disp('Wystąpił błąd podczas wczytywania pliku:');
    disp(ME.message);
    return; % Zakończ skrypt, jeśli nie udało się wczytać danych
end

% 2. DEFINICJA NAZW KOLUMN I PARAMETRÓW TESTU
% !!! ZASTĄP PONIŻSZE NAZWY RZECZYWISTYMI NAZWAMI KOLUMN Z TWOJEJ TABELI !!!
makeColumnName = 'Make'; % Rzeczywista nazwa kolumny z marką
co2ColumnName = 'CO2Emissions_g_km_'; % Rzeczywista nazwa kolumny z CO2

alpha_normality_check = 0.05; % Poziom istotności dla testów normalności
min_sample_size_for_test = 8; % Minimalna rozsądna wielkość próby dla testu Shapiro-Wilka
                               % Dla Lillieforsa może być mniejsza, ale testy na małych próbach mają małą moc

% Sprawdzenie, czy kolumny istnieją
if ~ismember(makeColumnName, dataTable.Properties.VariableNames)
    error(['Kolumna marki "' makeColumnName '" nie istnieje w tabeli. Sprawdź nazwy.']);
end
if ~ismember(co2ColumnName, dataTable.Properties.VariableNames)
    error(['Kolumna CO2 "' co2ColumnName '" nie istnieje w tabeli. Sprawdź nazwy.']);
end

% 3. POBRANIE UNIKALNYCH MAREK
% Upewniamy się, że pracujemy z typem danych, który obsługuje unique poprawnie
makeData = dataTable.(makeColumnName);
if iscellstr(makeData)
    uniqueMakes = unique(makeData);
elseif iscategorical(makeData)
    uniqueMakes = categories(makeData); % Dla categorical, categories() zwraca cellstr
    % uniqueMakes = cellstr(unique(makeData)); % Alternatywa
elseif isstring(makeData)
    uniqueMakes = unique(makeData);
    uniqueMakes = cellstr(uniqueMakes); % Konwersja na cellstr dla spójności w pętli
else
    error('Nieobsługiwany typ danych dla kolumny marki. Dostosuj kod.');
end

fprintf('Znaleziono %d unikalnych marek. Rozpoczynam testowanie normalności...\n', length(uniqueMakes));

% 4. TESTOWANIE NORMALNOŚCI DLA KAŻDEJ MARKI
normal_brands = {}; % Lista marek z normalnym rozkładem CO2

disp('-----------------------------------------------------------------');
for i = 1:length(uniqueMakes)
    currentMakeStr = uniqueMakes{i}; % currentMakeStr jest teraz zawsze char array lub string
    
    % Filtrowanie danych dla bieżącej marki
    isCurrentMakeLogic = [];
    if isstring(dataTable.(makeColumnName))
        isCurrentMakeLogic = (dataTable.(makeColumnName) == string(currentMakeStr));
    elseif iscellstr(dataTable.(makeColumnName))
        isCurrentMakeLogic = strcmp(dataTable.(makeColumnName), currentMakeStr);
    elseif iscategorical(dataTable.(makeColumnName))
        isCurrentMakeLogic = (dataTable.(makeColumnName) == categorical({currentMakeStr}));
    end
    
    dataForBrand = dataTable.(co2ColumnName)(isCurrentMakeLogic);
    dataForBrand_no_nan = dataForBrand(~isnan(dataForBrand));
    
    fprintf('Testuję markę: %s (N=%d, N po usunięciu NaN=%d)\n', currentMakeStr, length(dataForBrand), length(dataForBrand_no_nan));
    
    if length(dataForBrand_no_nan) < min_sample_size_for_test
        fprintf('  Za mało danych (N=%d) dla marki %s do przeprowadzenia wiarygodnego testu normalności.\n', length(dataForBrand_no_nan), currentMakeStr);
        disp('-----------------------------------------------------------------');
        continue;
    end
    
    % Wybór testu normalności
    test_used = '';
    p_value = NaN;
    h_decision = NaN; % 0 = H0 nie odrzucona (normalny), 1 = H0 odrzucona (nie normalny)
    
    % Spróbuj użyć swtest, jeśli dostępny
    if exist('swtest', 'file') == 2 % Sprawdza czy funkcja swtest istnieje
        try
            [h_decision, p_value] = swtest(dataForBrand_no_nan, alpha_normality_check);
            test_used = 'Shapiro-Wilka';
        catch ME_sw
            fprintf('  Błąd podczas używania swtest dla %s: %s. Próbuję Lillieforsa.\n', currentMakeStr, ME_sw.message);
            % Jeśli swtest zawiedzie (np. dla bardzo małych N lub specyficznych danych), spróbuj lillietest
            [h_decision, p_value] = lillietest(dataForBrand_no_nan, 'Alpha', alpha_normality_check);
            test_used = 'Lillieforsa (po błędzie swtest)';
        end
    else % Jeśli swtest nie jest dostępny, użyj lillietest
        [h_decision, p_value] = lillietest(dataForBrand_no_nan, 'Alpha', alpha_normality_check);
        test_used = 'Lillieforsa';
    end
    
    fprintf('  Test %s: p-value = %.4f, H = %d\n', test_used, p_value, h_decision);
    
    if h_decision == 0 % H0 nie odrzucona -> dane MOŻNA uznać za normalne
        fprintf('  => Rozkład CO2 dla marki %s MOŻE być uznany za normalny (p >= %.2f).\n', currentMakeStr, alpha_normality_check);
        normal_brands{end+1} = currentMakeStr; %#ok<SAGROW>
    else % H0 odrzucona -> dane NIE są normalne
        fprintf('  => Rozkład CO2 dla marki %s NIE jest normalny (p < %.2f).\n', currentMakeStr, alpha_normality_check);
    end
    disp('-----------------------------------------------------------------');
end

% 5. WYŚWIETLENIE WYNIKU KOŃCOWEGO
fprintf('\n=== Podsumowanie ===\n');
if isempty(normal_brands)
    disp('Żadna z analizowanych marek (z wystarczającą ilością danych) nie wykazała normalnego rozkładu emisji CO2.');
else
    disp('Marki, dla których rozkład emisji CO2 MOŻE być uznany za normalny (p >= alpha):');
    for i = 1:length(normal_brands)
        disp(['- ', normal_brands{i}]);
    end
end
fprintf('Użyty poziom istotności alpha = %.2f\n', alpha_normality_check);
fprintf('Minimalna wielkość próby do testu = %d\n', min_sample_size_for_test);

% --- KONIEC SKRYPTU ---