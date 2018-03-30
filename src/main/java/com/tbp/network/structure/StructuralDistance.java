package com.tbp.network.structure;


import org.graphstream.graph.Graph;

import java.util.List;
import java.util.Map;

public class StructuralDistance {

    DegreeSequence degreeSequence;
    DTW dtw;

    public StructuralDistance(DegreeSequence degreeSequence, DTW dtw) {
        this.degreeSequence = degreeSequence;
        this.dtw = dtw;
    }

    public double execute(Graph g, String node1, String node2, int maxDistance) {
        int i = 0;
        Map<Integer, List<Integer>> s = degreeSequence.execute(node1, g);
        Map<Integer, List<Integer>> t = degreeSequence.execute(node2, g);
        double sum = 0d;
        while(i <= maxDistance) {
            double val = dtw.execute(s.get(i), t.get(i));
            sum = sum + val;
            i++;
        }
        return sum;
    }
}
