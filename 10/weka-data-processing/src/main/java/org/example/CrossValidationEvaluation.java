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

public class CrossValidationEvaluation {

    public static void main(String[] args) throws Exception {
        // Parametry: ścieżka, liczba foldów, liczba powtórzeń, nazwa klasyfikatora
        String filePath = "264019L4 1.arff";
        int folds = 10;
        int repeats = 5;
        String classifierName = "JRip"; // np. "ZeroR", "NaiveBayes", "JRip", "J48", "SMO", "MultilayerPerceptron"
        Instances data = new DataSource(filePath).getDataSet();
        data.setClassIndex(data.numAttributes() - 1);

        // Dynamiczne wykrycie klasy pozytywnej "zly"
        int posClassIndex = data.classAttribute().indexOfValue("zly");
        int negClassIndex = 1 - posClassIndex;

        double[][] confusionMatrixSum = new double[2][2];
        double accSum = 0, tprSum = 0, tnrSum = 0, gmeanSum = 0, aucSum = 0;

        for (int r = 0; r < repeats; r++) {
            Instances randData = new Instances(data);
            randData.randomize(new Random(r));

            Evaluation eval = new Evaluation(randData);

            for (int f = 0; f < folds; f++) {
                Instances train = randData.trainCV(folds, f);
                Instances test = randData.testCV(folds, f);

                Classifier cls = getClassifier(classifierName);
                cls.buildClassifier(train);
                eval.evaluateModel(cls, test);
            }

            double[][] cm = eval.confusionMatrix();
            for (int i = 0; i < 2; i++)
                for (int j = 0; j < 2; j++)
                    confusionMatrixSum[i][j] += cm[i][j];

            double TP = cm[posClassIndex][posClassIndex];
            double FN = cm[posClassIndex][negClassIndex];
            double FP = cm[negClassIndex][posClassIndex];
            double TN = cm[negClassIndex][negClassIndex];

            double TPR = TP / (TP + FN);
            double TNR = TN / (TN + FP);
            double ACC = (TP + TN) / (TP + TN + FP + FN);
            double GMean = Math.sqrt(TPR * TNR);

            accSum += ACC;
            tprSum += TPR;
            tnrSum += TNR;
            gmeanSum += GMean;
            aucSum += eval.weightedAreaUnderROC();
        }

        // Średnie
        System.out.println("=== ŚREDNIA MACIERZ KONFUZJI ===");
        System.out.printf("%35s%30s\n", "Zaklasyfikowany do pozytywnej", "Zaklasyfikowany do negatywnej");
        System.out.printf("Należy do klasy pozytywnej    TP = %.2f           FN = %.2f\n", confusionMatrixSum[posClassIndex][posClassIndex] / repeats, confusionMatrixSum[posClassIndex][negClassIndex] / repeats);
        System.out.printf("Należy do klasy negatywnej    FP = %.2f           TN = %.2f\n", confusionMatrixSum[negClassIndex][posClassIndex] / repeats, confusionMatrixSum[negClassIndex][negClassIndex] / repeats);

        System.out.println("\n=== METRYKI ===");
        System.out.printf("Accuracy: %.4f\n", accSum / repeats);
        System.out.printf("TPRate (czułość): %.4f\n", tprSum / repeats);
        System.out.printf("TNRate (specyficzność): %.4f\n", tnrSum / repeats);
        System.out.printf("GMean: %.4f\n", gmeanSum / repeats);
        System.out.printf("AUC: %.4f\n", aucSum / repeats);
    }

    public static Classifier getClassifier(String name) throws Exception {
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