package com.tbp.network.structure;


import com.tbp.network.structure.degreeseq.DegreeSequence;
import com.tbp.network.structure.dtw.DTW;
import com.tbp.network.structure.model.StructuralDistanceDto;
import org.graphstream.graph.Graph;
import org.graphstream.graph.Node;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.*;

/**
 * Class that calculates the structural distance between every node of a graph
 */
public class StructuralDistance {
    private static final Logger LOGGER = LoggerFactory.getLogger(StructuralDistance.class);
    DegreeSequence degreeSequence;
    DTW dtw;

    public StructuralDistance(DegreeSequence degreeSequence, DTW dtw) {
        this.degreeSequence = degreeSequence;
        this.dtw = dtw;
    }

    public Map<String, StructuralDistanceDto> execute(Graph g, int maxDistance) {
        Map<String, StructuralDistanceDto>  strucDistHashMap = new HashMap<String, StructuralDistanceDto>();
        Iterator<? extends Node> node1Iterator = g.getEachNode().iterator();
        while(node1Iterator.hasNext()) {
            long startTime = System.currentTimeMillis();
            Node firstNode = node1Iterator.next();
            String node1 = firstNode.getId();
            Iterator<? extends Node> node2Iterator = g.getEachNode().iterator();
            while(node2Iterator.hasNext()) {
                Node secondNode = node2Iterator.next();
                String node2 = secondNode.getId();
                String id = StructuralDistanceDto.generateId(node1, node2);
                if(!node1.equals(node2) && !strucDistHashMap.containsKey(id)) {
                    double distance = this.execute(g, node1, node2, maxDistance);
                    StructuralDistanceDto dto = new StructuralDistanceDto(node1, node2, distance);
                    strucDistHashMap.put(dto.getId(), dto);
                }
             }
            long totalTime = (System.currentTimeMillis() - startTime);
            LOGGER.trace("Calc. structural distance of node {} to all. It took {} ms.", node1, totalTime);
        }
        return strucDistHashMap;
    }

    public double execute(Graph g, String node1, String node2, int maxDistance) {
        int i = 0;
        Map<Integer, List<Integer>> s = degreeSequence.execute(node1, g, maxDistance);
        Map<Integer, List<Integer>> t = degreeSequence.execute(node2, g, maxDistance);
        double sum = 0d;
        while(i <= maxDistance) {
            double val = dtw.execute(s.get(i), t.get(i));
            sum = sum + val;
            i++;
        }
        return sum;
    }
}
