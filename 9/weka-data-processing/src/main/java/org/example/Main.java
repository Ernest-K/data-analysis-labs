package org.example;


public class Main {

    public static void main(String[] args) throws Exception {
        String inputFile = "264019L3 1.arff";

        try {
            double base = 2.0;
            System.out.println("Podstawa algorytmu: " + base);
            CustomGainRatioAttributeEval eval = new CustomGainRatioAttributeEval(inputFile, base);
            eval.evaluateAttributes();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

