package com.tbp.network.structure;


import com.tbp.network.structure.degreeseq.DegreeSequence;
import com.tbp.network.structure.dtw.DTW;
import org.graphstream.graph.Graph;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Map;

@Component
public class StructuralDistanceSupport {
    private static final Logger LOGGER = LoggerFactory.getLogger(StructuralDistanceSupport.class);

    @Autowired
    DegreeSequence degreeSequence;
    @Autowired
    DTW dtw;


    public double dtwBetweenNodes(Graph g, String node1, String node2, int maxDistance) {
        int i = 0;
        Map<Integer, List<Integer>> s = degreeSequence.execute(node1, g, maxDistance);
        Map<Integer, List<Integer>> t = degreeSequence.execute(node2, g, maxDistance);
        double sum = 0d;
        if(s.size() != t.size()) {
            LOGGER.trace("Could not find structural distance between {} and {} with max hop-count {}", node1, node2, maxDistance);
            if(s.size() > t.size()) {
                maxDistance = t.size() - 1;
            } else {
                maxDistance = s.size() - 1;
            }
            LOGGER.trace("Max hop-count considered {}", maxDistance);
        } else{
            LOGGER.trace("Degree sequence with same size for node {} and node {}", node1, node2);
        }
        while(i <= maxDistance) {
            double val = dtw.execute(s.get(i), t.get(i));
            sum = sum + val;
            i++;
        }
        return sum;
    }

}
