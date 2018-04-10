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


public class ThirdQuStructuralDistance extends StructuralDistance {

    private static final Logger LOGGER = LoggerFactory.getLogger(ThirdQuStructuralDistance.class);

    public ThirdQuStructuralDistance(DegreeSequence degreeSequence, DTW dtw, PerformanceTime performanceTime) {
        super(degreeSequence, dtw, performanceTime);
    }

    public Map<String, StructuralDistanceDto> execute(NetworkModel model, int maxDistance) {
        performanceTime.addStartTime("COMPLETE_STRUCTURAL_EXECUTION");
        Map<String, StructuralDistanceDto>  strucDistHashMap = new HashMap<String, StructuralDistanceDto>();
        Map<String, List<Integer>> nodeCategory = getNodeCategory(model);
        LOGGER.info("Executing low degree nodes");
        execute(model, maxDistance, strucDistHashMap, nodeCategory.get("low"));
        LOGGER.info("Executing high degree nodes");
        execute(model, maxDistance, strucDistHashMap, nodeCategory.get("high"));
        performanceTime.addTotalTime("COMPLETE_STRUCTURAL_EXECUTION");
        return strucDistHashMap;
    }

    Map<String, List<Integer>> getNodeCategory(NetworkModel model) {
        Map<String, List<Integer>> map = new HashMap<>();
        map.put("low", new ArrayList<Integer>());
        map.put("high", new ArrayList<Integer>());
        Graph g = model.getGraph();
        Iterator<? extends Node> node1Iterator = g.getEachNode().iterator();
        while(node1Iterator.hasNext()) {
            Node node = node1Iterator.next();
            if(isLowDegreeNode(model, node)) {
                map.get("low").add(node.getIndex());
            } else {
                map.get("high").add(node.getIndex());
            }
        }
        return map;
    }

    void execute(NetworkModel model, int maxDistance, Map<String, StructuralDistanceDto>  strucDistHashMap, List<Integer> nodeIndexList) {
        Graph g = model.getGraph();
        for(int i = 0; i < nodeIndexList.size(); i++) {
            Integer nodeIndex = nodeIndexList.get(i);
            Node firstNode = g.getNode(nodeIndex);
            String node1 = firstNode.getId();
            for(int j = 0; j < nodeIndexList.size(); j++) {
                nodeIndex = nodeIndexList.get(j);
                Node secondNode = g.getNode(nodeIndex);
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
    }

    boolean isLowDegreeNode(NetworkModel model, Node node) {
        if(node.getDegree() <= ( model.getThirdQuDegree())) {
            return true;
        }
        return false;
    }

}
