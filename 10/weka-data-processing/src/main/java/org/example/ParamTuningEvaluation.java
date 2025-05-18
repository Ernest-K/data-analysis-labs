package org.example;
import weka.classifiers.*;
import weka.classifiers.bayes.NaiveBayes;
import weka.classifiers.functions.MultilayerPerceptron;
import weka.classifiers.functions.SMO;
import weka.classifiers.rules.JRip;
import weka.classifiers.rules.ZeroR;
import weka.classifiers.trees.J48;
import weka.core.Instances;
import weka.core.converters.ConverterUtils.DataSource;

import java.util.Random;

public class ParamTuningEvaluation {

    public static void main(String[] args) throws Exception {
        String filePath = "264019L4 1.arff";
        int folds = 10;
        int repeats = 5;

        Instances data = new DataSource(filePath).getDataSet();
        data.setClassIndex(data.numAttributes() - 1);

        int posIndex = data.classAttribute().indexOfValue("zly");
        int negIndex = 1 - posIndex;

        System.out.printf("%-25s %-15s %10s %10s %10s %10s %10s\n", "Classifier", "Parametry", "GMean", "AUC", "Accuracy", "TPRate", "TNRate");

        // Proste klasyfikatory bez parametrów
        evaluate("ZeroR", new ZeroR(), data, folds, repeats, posIndex, negIndex, "default");
        evaluate("JRip", new JRip(), data, folds, repeats, posIndex, negIndex, "default");
        evaluate("NaiveBayes", new NaiveBayes(), data, folds, repeats, posIndex, negIndex, "default");

        // J48 - test różnych wartości confidence factor
        for (double c : new double[]{0.1, 0.25, 0.5}) {
            J48 j48 = new J48();
            j48.setConfidenceFactor((float) c);
            evaluate("J48", j48, data, folds, repeats, posIndex, negIndex, "C=" + c);
        }

        // SMO - test różnych wartości parametru C
        for (double c : new double[]{0.1, 1.0, 10.0}) {
            SMO smo = new SMO();
            smo.setC(c);
            evaluate("SMO", smo, data, folds, repeats, posIndex, negIndex, "C=" + c);
        }

        // MultilayerPerceptron - różne struktury ukryte
        for (String h : new String[]{"a", "3", "5"}) {
            MultilayerPerceptron mlp = new MultilayerPerceptron();
            mlp.setHiddenLayers(h);
            mlp.setTrainingTime(200);
            evaluate("MLP", mlp, data, folds, repeats, posIndex, negIndex, "hidden=" + h);
        }
    }

    private static void evaluate(String name, Classifier cls, Instances data, int folds, int repeats, int posIndex, int negIndex, String param) throws Exception {
        double accSum = 0, tprSum = 0, tnrSum = 0, gmeanSum = 0, aucSum = 0;

        for (int r = 0; r < repeats; r++) {
            Instances randData = new Instances(data);
            randData.randomize(new Random(r));

            Evaluation eval = new Evaluation(randData);

            for (int f = 0; f < folds; f++) {
                Instances train = randData.trainCV(folds, f);
                Instances test = randData.testCV(folds, f);

                Classifier copy = AbstractClassifier.makeCopy(cls);
                copy.buildClassifier(train);
                eval.evaluateModel(copy, test);
            }

            double[][] cm = eval.confusionMatrix();

            double TP = cm[posIndex][posIndex];
            double FN = cm[posIndex][negIndex];
            double FP = cm[negIndex][posIndex];
            double TN = cm[negIndex][negIndex];

            double TPR = (TP + FN) == 0 ? 0 : TP / (TP + FN);
            double TNR = (TN + FP) == 0 ? 0 : TN / (TN + FP);
            double ACC = (TP + TN) / (TP + TN + FP + FN);
            double GMean = Math.sqrt(TPR * TNR);
            double AUC = eval.weightedAreaUnderROC();

            accSum += ACC;
            tprSum += TPR;
            tnrSum += TNR;
            gmeanSum += GMean;
            aucSum += AUC;
        }

        System.out.printf("%-25s %-15s %10.4f %10.4f %10.4f %10.4f %10.4f\n",
                name, param,
                gmeanSum / repeats,
                aucSum / repeats,
                accSum / repeats,
                tprSum / repeats,
                tnrSum / repeats);
    }
}