package org.example;

import weka.core.Instances;
import weka.core.converters.ArffSaver;
import weka.core.converters.ArffLoader;
import weka.filters.Filter;
import weka.filters.unsupervised.instance.RemoveWithValues;
import weka.filters.unsupervised.attribute.Remove;

import java.io.File;

public class Main {
    public static void main(String[] args) {
        try {
            // Wczytanie zbioru danych
            ArffLoader loader = new ArffLoader();
            loader.setSource(new File("264019L2 2.arff"));
            Instances data = loader.getDataSet();

            System.out.println("Plik został poprawnie wczytany!");
            System.out.println("Liczba rekordów: " + data.numInstances());
            System.out.println("Liczba atrybutów: " + data.numAttributes());

            // 1. Usunięcie rekordów, dla których status pożyczki = odmowa
            RemoveWithValues removeOdmowa = new RemoveWithValues();
            removeOdmowa.setAttributeIndex("" + (data.attribute("status pozyczki").index() + 1));
            removeOdmowa.setNominalIndices("" + (data.attribute("status pozyczki").indexOfValue("odmowa") + 1));
            removeOdmowa.setInputFormat(data);
            data = Filter.useFilter(data, removeOdmowa);

            // 2. Usunięcie rekordów, dla których wartość pożyczki > 900 zł
            RemoveWithValues removeLargeLoans = new RemoveWithValues();
            removeLargeLoans.setAttributeIndex("" + (data.attribute("kwota kredytu").index() + 1));
            removeLargeLoans.setMatchMissingValues(false);
            removeLargeLoans.setSplitPoint(900.0);
            removeLargeLoans.setInvertSelection(true);
            removeLargeLoans.setInputFormat(data);
            data = Filter.useFilter(data, removeLargeLoans);

            // 3. Usunięcie atrybutu status pożyczki
            Remove removeAttribute = new Remove();
            removeAttribute.setAttributeIndices("" + (data.attribute("status pozyczki").index() + 1));
            removeAttribute.setInputFormat(data);
            data = Filter.useFilter(data, removeAttribute);

            // Zapisanie przetworzonego zbioru danych
            ArffSaver saver = new ArffSaver();
            saver.setInstances(data);
            saver.setFile(new File("264019L3 2.arff"));
            saver.writeBatch();

            System.out.println("Przetwarzanie zakończone. Plik 264019L3 2.arff został utworzony.");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}