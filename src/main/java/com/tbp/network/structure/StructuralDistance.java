package com.tbp.network.structure;

import com.tbp.network.model.NetworkModel;
import com.tbp.network.performance.PerformanceTime;
import com.tbp.network.structure.degreeseq.DegreeSequence;
import com.tbp.network.structure.dtw.DTW;
import com.tbp.network.structure.model.StructuralDistanceDto;
import org.graphstream.graph.Graph;

import java.util.List;
import java.util.Map;


public abstract class StructuralDistance {

    DegreeSequence degreeSequence;
    DTW dtw;
    PerformanceTime performanceTime;

    public StructuralDistance(DegreeSequence degreeSequence, DTW dtw, PerformanceTime performanceTime) {
        this.degreeSequence = degreeSequence;
        this.dtw = dtw;
        this.performanceTime = performanceTime;
    }

    public abstract Map<String, StructuralDistanceDto> execute(NetworkModel model, int maxDistance) ;

    double dtwBetweenNodes(Graph g, String node1, String node2, int maxDistance) {
        performanceTime.addStartTime("DEGREE_SEQUENCE");
        int i = 0;
        Map<Integer, List<Integer>> s = degreeSequence.execute(node1, g, maxDistance);
        Map<Integer, List<Integer>> t = degreeSequence.execute(node2, g, maxDistance);
        performanceTime.addTotalTime("DEGREE_SEQUENCE");

        performanceTime.addStartTime("DTW_FUNCTION");
        double sum = 0d;
        while(i <= maxDistance) {
            double val = dtw.execute(s.get(i), t.get(i));
            sum = sum + val;
            i++;
        }
        performanceTime.addTotalTime("DTW_FUNCTION");
        return sum;
    }
}
