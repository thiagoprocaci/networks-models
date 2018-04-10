package com.tbp.network.structure;


import com.tbp.network.model.NetworkModel;
import com.tbp.network.performance.PerformanceTime;
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
public class CompleteStructuralDistance extends StructuralDistance {
    private static final Logger LOGGER = LoggerFactory.getLogger(CompleteStructuralDistance.class);


    public CompleteStructuralDistance(DegreeSequence degreeSequence, DTW dtw, PerformanceTime performanceTime) {
       super(degreeSequence, dtw, performanceTime);
    }

    public Map<String, StructuralDistanceDto> execute(NetworkModel model, int maxDistance) {
        Graph g = model.getGraph();
        performanceTime.addStartTime("COMPLETE_STRUCTURAL_EXECUTION");
        Map<String, StructuralDistanceDto>  strucDistHashMap = new HashMap<String, StructuralDistanceDto>();
        Iterator<? extends Node> node1Iterator = g.getEachNode().iterator();
        while(node1Iterator.hasNext()) {
            Node firstNode = node1Iterator.next();
            String node1 = firstNode.getId();
            Iterator<? extends Node> node2Iterator = g.getEachNode().iterator();
            while(node2Iterator.hasNext()) {
                Node secondNode = node2Iterator.next();
                String node2 = secondNode.getId();
                String id = StructuralDistanceDto.generateId(node1, node2);
                performanceTime.addStartTime("MAP_CONTAINS");
                boolean x = !strucDistHashMap.containsKey(id);
                performanceTime.addTotalTime("MAP_CONTAINS");
                if(!node1.equals(node2) && x) {
                    double distance = this.dtwBetweenNodes(g, node1, node2, maxDistance);
                    performanceTime.addStartTime("STRUCTURAL_DTO_CREATION");
                    StructuralDistanceDto dto = new StructuralDistanceDto(node1, node2, distance);
                    strucDistHashMap.put(dto.getId(), dto);
                    performanceTime.addTotalTime("STRUCTURAL_DTO_CREATION");
                }
             }
        }
        performanceTime.addTotalTime("COMPLETE_STRUCTURAL_EXECUTION");
        return strucDistHashMap;
    }


}
