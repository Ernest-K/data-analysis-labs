package org.example;

import weka.classifiers.Classifier;
import weka.classifiers.Evaluation;
import weka.classifiers.bayes.NaiveBayes;
import weka.classifiers.functions.MultilayerPerceptron;
import weka.classifiers.functions.SMO;
import weka.classifiers.rules.JRip;
import weka.classifiers.rules.ZeroR;
import weka.classifiers.trees.J48;
import weka.core.Instances;
import weka.core.converters.ConverterUtils.DataSource;
import weka.core.Utils;
import weka.classifiers.evaluation.ThresholdCurve;
import weka.core.Attribute;
import weka.core.Instance;

import java.util.Random;

public class Test {

    public static void main(String[] args) throws Exception {
        // Parametry: ścieżka, liczba foldów, liczba powtórzeń, nazwa klasyfikatora
        String filePath = "264019L4 1.arff";
        int numFolds = 10;
        int numRepeats = 5;
        String classifierName = "JRip"; // np. "ZeroR", "NaiveBayes", "JRip", "J48", "SMO", "MultilayerPerceptron"

        DataSource source = new DataSource(filePath);
        Instances data = source.getDataSet();

        // Ustaw klasę (ostatni atrybut)
        data.setClassIndex(data.numAttributes() - 1);

        // Klasa pozytywna to "zly"
        String positiveClass = "zly";
        int positiveIndex = data.classAttribute().indexOfValue(positiveClass);

        double[][] confusionMatrixSum = new double[2][2];
        double aucSum = 0;
        double accSum = 0, tprSum = 0, tnrSum = 0, gmeanSum = 0;

        for (int repeat = 0; repeat < numRepeats; repeat++) {
            Instances randData = new Instances(data);
            randData.randomize(new Random(repeat));

            Evaluation eval = new Evaluation(randData);

            for (int fold = 0; fold < numFolds; fold++) {
                Instances train = randData.trainCV(numFolds, fold);
                Instances test = randData.testCV(numFolds, fold);

                Classifier cls = getClassifier(classifierName);
                cls.buildClassifier(train);

                eval.evaluateModel(cls, test);
            }

            double[][] cm = eval.confusionMatrix();
            for (int i = 0; i < 2; i++)
                for (int j = 0; j < 2; j++)
                    confusionMatrixSum[i][j] += cm[i][j];

            double TP = cm[positiveIndex][positiveIndex];
            double FN = cm[positiveIndex][1 - positiveIndex];
            double FP = cm[1 - positiveIndex][positiveIndex];
            double TN = cm[1 - positiveIndex][1 - positiveIndex];

            double TPR = TP / (TP + FN);
            double TNR = TN / (TN + FP);
            double ACC = (TP + TN) / (TP + TN + FP + FN);
            double GMean = Math.sqrt(TPR * TNR);

            aucSum += eval.weightedAreaUnderROC();
            accSum += ACC;
            tprSum += TPR;
            tnrSum += TNR;
            gmeanSum += GMean;
        }

        // Średnie wartości
        System.out.println("Średnia macierz konfuzji:");
        for (double[] row : confusionMatrixSum) {
            for (double v : row)
                System.out.printf("%.2f ", v / numRepeats);
            System.out.println();
        }

        System.out.printf("Accuracy: %.4f\n", accSum / numRepeats);
        System.out.printf("TPRate (czułość): %.4f\n", tprSum / numRepeats);
        System.out.printf("TNRate (specyficzność): %.4f\n", tnrSum / numRepeats);
        System.out.printf("GMean: %.4f\n", gmeanSum / numRepeats);
        System.out.printf("AUC: %.4f\n", aucSum / numRepeats);
    }

    public static Classifier getClassifier(String name) {
        return switch (name) {
            case "ZeroR" -> new ZeroR();
            case "JRip" -> new JRip();
            case "J48" -> new J48();
            case "SMO" -> new SMO();
            case "MultilayerPerceptron" -> new MultilayerPerceptron();
            case "NaiveBayes" -> new NaiveBayes();
            default -> throw new IllegalArgumentException("Nieznany klasyfikator: " + name);
        };
    }
}
