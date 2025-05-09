package org.example;

import weka.core.Instances;
import weka.core.Instance;
import weka.core.Attribute;
import weka.core.converters.ArffLoader;
import weka.filters.supervised.attribute.Discretize;
import weka.attributeSelection.GainRatioAttributeEval;
import java.io.File;
import java.util.*;

public class Main {

    public static void main(String[] args) throws Exception {
        String inputFile = "264019L3 1.arff";

        try {
            double base = 2.0;
            System.out.println("Używam podstawy logarytmu: " + base);
            CustomGainRatioAttributeEval eval = new CustomGainRatioAttributeEval(inputFile, base);
            eval.evaluateAttributes();
        } catch (NumberFormatException e) {
            System.out.println("Niepoprawny format podstawy logarytmu. Używam domyślnej podstawy 2.0");
            CustomGainRatioAttributeEval eval = new CustomGainRatioAttributeEval(inputFile, 2.0);
            eval.evaluateAttributes();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

class CustomGainRatioAttributeEval {
    private double logBase = 2.0;
    private Instances data;
    private int classIndex;

    public CustomGainRatioAttributeEval(String filename, double logBase) throws Exception {
        this.logBase = logBase;

        // Wczytanie danych
        ArffLoader loader = new ArffLoader();
        loader.setSource(new File(filename));
        data = loader.getDataSet();

        // Zakładamy, że ostatni atrybut jest klasą
        data.setClassIndex(data.numAttributes() - 1);
        classIndex = data.classIndex();

        // Dyskretyzacja atrybutów numerycznych (tryb nadzorowany)
        discretizeNumericAttributes();
    }

    private void discretizeNumericAttributes() throws Exception {
        Discretize discretize = new Discretize();
        discretize.setUseBetterEncoding(true);
        discretize.setUseKononenko(true); // Tryb nadzorowany
        discretize.setInputFormat(data);
        data = weka.filters.Filter.useFilter(data, discretize);
    }

    public void evaluateAttributes() throws Exception {
        double classEntropy = calculateClassEntropy();
        System.out.println("Entropia klasy: " + classEntropy);

        GainRatioAttributeEval wekaEval = new GainRatioAttributeEval();
        wekaEval.buildEvaluator(data);

        Map<String, Double> gainRatioMap = new HashMap<>();
        for (int i = 0; i < data.numAttributes(); i++) {
            if (i != classIndex) {
                double attrEntropy = calculateAttributeEntropy(i);
                double condEntropy = calculateConditionalEntropy(i);
                double infoGain = classEntropy - condEntropy;
                double gainRatio = (attrEntropy > 0) ? infoGain / attrEntropy : 0;

                double wekaGainRatio = wekaEval.evaluateAttribute(i);
                String attrName = data.attribute(i).name();
                gainRatioMap.put(attrName, gainRatio);

                System.out.println("Atrybut: " + attrName);
                System.out.println("  Entropia atrybutu: " + attrEntropy);
                System.out.println("  Entropia warunkowa: " + condEntropy);
                System.out.println("  InfoGain: " + infoGain);
                System.out.println("  GainRatio (własna impl.): " + gainRatio);
                System.out.println("  GainRatio (Weka): " + wekaGainRatio);
                System.out.println("  Różnica: " + Math.abs(gainRatio - wekaGainRatio));
                System.out.println();
            }
        }

        List<Map.Entry<String, Double>> sortedEntries = new ArrayList<>(gainRatioMap.entrySet());
        sortedEntries.sort(Map.Entry.comparingByValue());
        Collections.reverse(sortedEntries);

        System.out.println("\nAtrybuty uporządkowane rosnąco według GainRatio:");
        for (Map.Entry<String, Double> entry : sortedEntries) {
            System.out.println(entry.getKey() + ": " + entry.getValue());
        }
    }

    private double calculateClassEntropy() {
        int numClasses = data.numClasses();
        int totalInstances = data.numInstances();
        double[] classCounts = new double[numClasses];

        for (int i = 0; i < totalInstances; i++) {
            int classValue = (int) data.instance(i).classValue();
            classCounts[classValue]++;
        }

        double entropy = 0;
        for (int i = 0; i < numClasses; i++) {
            if (classCounts[i] > 0) {
                double probability = classCounts[i] / totalInstances;
                entropy -= probability * log(probability);
            }
        }
        return entropy;
    }

    private double calculateAttributeEntropy(int attributeIndex) {
        Attribute attribute = data.attribute(attributeIndex);
        int numValues = attribute.numValues();
        int totalInstances = data.numInstances();
        double[] valueCounts = new double[numValues];

        for (int i = 0; i < totalInstances; i++) {
            Instance instance = data.instance(i);
            if (!instance.isMissing(attributeIndex)) {
                int valueIndex = (int) instance.value(attributeIndex);
                valueCounts[valueIndex]++;
            }
        }

        double entropy = 0;
        for (int i = 0; i < numValues; i++) {
            if (valueCounts[i] > 0) {
                double probability = valueCounts[i] / totalInstances;
                entropy -= probability * log(probability);
            }
        }
        return entropy;
    }

    private double calculateConditionalEntropy(int attributeIndex) {
        Attribute attribute = data.attribute(attributeIndex);
        int numValues = attribute.numValues();
        int numClasses = data.numClasses();
        int totalInstances = data.numInstances();

        double[][] counts = new double[numValues][numClasses];
        double[] valueCounts = new double[numValues];

        for (int i = 0; i < totalInstances; i++) {
            Instance instance = data.instance(i);
            if (!instance.isMissing(attributeIndex)) {
                int valueIndex = (int) instance.value(attributeIndex);
                int classValue = (int) instance.classValue();
                counts[valueIndex][classValue]++;
                valueCounts[valueIndex]++;
            }
        }

        double conditionalEntropy = 0;
        for (int i = 0; i < numValues; i++) {
            if (valueCounts[i] > 0) {
                double valueProb = valueCounts[i] / totalInstances;
                double entropyForValue = 0;

                for (int j = 0; j < numClasses; j++) {
                    if (counts[i][j] > 0) {
                        double condProb = counts[i][j] / valueCounts[i];
                        entropyForValue -= condProb * log(condProb);
                    }
                }
                conditionalEntropy += valueProb * entropyForValue;
            }
        }
        return conditionalEntropy;
    }

    private double log(double value) {
        return Math.log(value) / Math.log(logBase);
    }
}