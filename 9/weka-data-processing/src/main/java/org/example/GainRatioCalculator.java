package org.example;

import weka.core.Instances;
import weka.core.Instance;
import weka.core.Attribute;
import weka.core.converters.ArffLoader;
import weka.filters.Filter;
import weka.filters.supervised.attribute.Discretize;
import java.io.File;
import java.util.HashMap;
import java.util.Map;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Enumeration;

public class GainRatioCalculator {

    // Podstawa logarytmu do użycia przy obliczeniach entropii
    private static final double LOG_BASE = 2.0;
    // Liczba przedziałów do dyskretyzacji
    private static final int NUM_BINS = 5;

    public static void main(String[] args) {
        try {
            // Ścieżka do pliku ARFF
            String filePath = "264019L3 1.arff";
            if (args.length > 0) {
                filePath = args[0];
            }

            // Wczytanie pliku ARFF
            ArffLoader loader = new ArffLoader();
            loader.setSource(new File(filePath));
            Instances data = loader.getDataSet();

            // Ustawienie atrybutu klasy jako ostatniego atrybutu
            data.setClassIndex(data.numAttributes() - 1);
            String targetAttribute = data.classAttribute().name();

            System.out.println("Wczytano plik: " + filePath);
            System.out.println("Liczba instancji: " + data.numInstances());
            System.out.println("Liczba atrybutów: " + data.numAttributes());
            System.out.println("Atrybut klasy: " + targetAttribute);

            // Dyskretyzacja zmiennych numerycznych
            Instances discretizedData = discretizeNumericFeatures(data, NUM_BINS);

            // Obliczenie entropii całkowitej zbioru
            double totalEntropy = calculateEntropy(discretizedData);
            System.out.printf("Entropia całego zbioru: %.4f%n%n", totalEntropy);

            // Lista do przechowywania wyników
            ArrayList<AttributeResult> results = new ArrayList<>();

            // Obliczenia dla każdego atrybutu
            for (int i = 0; i < discretizedData.numAttributes(); i++) {
                if (i == discretizedData.classIndex()) {
                    continue; // Pomijamy atrybut klasy
                }

                Attribute attr = discretizedData.attribute(i);
                String attrName = attr.name();

                // Obliczenie InfoGain i SplitInfo
                double[] gainAndSplit = calculateInfoGainAndSplitInfo(discretizedData, i);
                double infoGain = gainAndSplit[0];
                double splitInfo = gainAndSplit[1];

                // Obliczenie GainRatio
                double gainRatio = 0;
                if (splitInfo > 0) {
                    gainRatio = infoGain / splitInfo;
                }

                results.add(new AttributeResult(attrName, infoGain, splitInfo, gainRatio));
            }

            // Sortowanie wyników według GainRatio malejąco
            Collections.sort(results);

            // Wyświetlenie wyników
            System.out.printf("%-30s %10s %12s %12s%n", "Atrybut", "InfoGain", "SplitInfo", "GainRatio");
            System.out.println("-".repeat(70));
            for (AttributeResult result : results) {
                System.out.printf("%-30s %10.4f %12.4f %12.4f%n",
                        result.attributeName, result.infoGain, result.splitInfo, result.gainRatio);
            }

            // Sprawdzenie różnych podstaw logarytmu
            System.out.println("\nTestowanie różnych podstaw logarytmu (dla pierwszego atrybutu):");
            double[] bases = {2.0, Math.E, 10.0};
            int testAttrIndex = 0;
            for (double base : bases) {
                double entropy = calculateEntropy(discretizedData, base);
                double[] gainAndSplit = calculateInfoGainAndSplitInfo(discretizedData, testAttrIndex, base);
                double gainRatio = gainAndSplit[0] / gainAndSplit[1];
                System.out.printf("Podstawa log = %.1f: Entropia = %.4f, GainRatio = %.4f%n",
                        base, entropy, gainRatio);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * Metoda dokonująca dyskretyzacji zmiennych numerycznych
     */
    private static Instances discretizeNumericFeatures(Instances data, int numBins) throws Exception {
        Discretize discretize = new Discretize();
        discretize.setInputFormat(data);
//        discretize.setBins(numBins);
//        discretize.setUseEqualFrequency(false);
        discretize.setMakeBinary(false);
        return Filter.useFilter(data, discretize);
    }

    /**
     * Metoda obliczająca entropię zbioru danych dla atrybutu klasy
     */
    private static double calculateEntropy(Instances data) {
        return calculateEntropy(data, LOG_BASE);
    }

    private static double calculateEntropy(Instances data, double base) {
        int classIndex = data.classIndex();
        int numClasses = data.attribute(classIndex).numValues();
        int numInstances = data.numInstances();

        // Zliczanie częstości klas
        double[] classCounts = new double[numClasses];
        Enumeration<Instance> instEnum = data.enumerateInstances();
        while (instEnum.hasMoreElements()) {
            Instance instance = instEnum.nextElement();
            int classValue = (int) instance.classValue();
            classCounts[classValue]++;
        }

        // Obliczenie entropii
        double entropy = 0;
        for (int i = 0; i < numClasses; i++) {
            if (classCounts[i] > 0) {
                double proportion = classCounts[i] / numInstances;
                entropy -= proportion * logBase(proportion, base);
            }
        }

        return entropy;
    }

    /**
     * Metoda obliczająca InfoGain i SplitInfo dla podanego atrybutu
     */
    private static double[] calculateInfoGainAndSplitInfo(Instances data, int attrIndex) {
        return calculateInfoGainAndSplitInfo(data, attrIndex, LOG_BASE);
    }

    private static double[] calculateInfoGainAndSplitInfo(Instances data, int attrIndex, double base) {
        double totalEntropy = calculateEntropy(data, base);
        int numInstances = data.numInstances();
        int classIndex = data.classIndex();

        Attribute attribute = data.attribute(attrIndex);
        int numValues = attribute.numValues();

        // Mapy dla zliczania instancji
        Map<Integer, Integer> valueCounts = new HashMap<>();
        Map<Integer, Map<Integer, Integer>> valueClassCounts = new HashMap<>();

        // Inicjalizacja map
        for (int i = 0; i < numValues; i++) {
            valueCounts.put(i, 0);
            valueClassCounts.put(i, new HashMap<>());
        }

        // Zliczanie instancji
        Enumeration<Instance> instEnum = data.enumerateInstances();
        while (instEnum.hasMoreElements()) {
            Instance instance = instEnum.nextElement();
            int attrValue = (int) instance.value(attrIndex);
            int classValue = (int) instance.classValue();

            // Aktualizacja liczników
            valueCounts.put(attrValue, valueCounts.get(attrValue) + 1);

            Map<Integer, Integer> classCountsForValue = valueClassCounts.get(attrValue);
            classCountsForValue.put(classValue, classCountsForValue.getOrDefault(classValue, 0) + 1);
        }

        // Obliczenie ważonej entropii i splitInfo
        double weightedEntropy = 0;
        double splitInfo = 0;

        for (int i = 0; i < numValues; i++) {
            int count = valueCounts.get(i);
            if (count > 0) {
                double proportion = (double) count / numInstances;

                // Obliczenie entropii dla tej wartości atrybutu
                double valueEntropy = 0;
                Map<Integer, Integer> classCounts = valueClassCounts.get(i);

                for (Map.Entry<Integer, Integer> entry : classCounts.entrySet()) {
                    double classProb = (double) entry.getValue() / count;
                    if (classProb > 0) {
                        valueEntropy -= classProb * logBase(classProb, base);
                    }
                }

                weightedEntropy += proportion * valueEntropy;
                splitInfo -= proportion * logBase(proportion, base);
            }
        }

        double infoGain = totalEntropy - weightedEntropy;
        return new double[] {infoGain, splitInfo};
    }

    /**
     * Logarytm o zadanej podstawie
     */
    private static double logBase(double value, double base) {
        return Math.log(value) / Math.log(base);
    }

    /**
     * Klasa do przechowywania wyników dla atrybutów
     */
    static class AttributeResult implements Comparable<AttributeResult> {
        String attributeName;
        double infoGain;
        double splitInfo;
        double gainRatio;

        public AttributeResult(String attributeName, double infoGain, double splitInfo, double gainRatio) {
            this.attributeName = attributeName;
            this.infoGain = infoGain;
            this.splitInfo = splitInfo;
            this.gainRatio = gainRatio;
        }

        @Override
        public int compareTo(AttributeResult other) {
            // Sortowanie malejąco po gainRatio
            return Double.compare(other.gainRatio, this.gainRatio);
        }
    }
}