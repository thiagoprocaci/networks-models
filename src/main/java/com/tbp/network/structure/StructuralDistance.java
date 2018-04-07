package com.tbp.network.structure;


import com.tbp.network.model.NetworkModel;
import com.tbp.network.performance.PerformanceTime;
import com.tbp.network.structure.degreeseq.DegreeSequence;
import com.tbp.network.structure.dtw.DTW;
import com.tbp.network.structure.model.StructuralDistanceDto;
import org.graphstream.graph.Edge;
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
    PerformanceTime performanceTime;

    Node[] sortedDegreeList;
    int[] nodeIndexList;

    public StructuralDistance(DegreeSequence degreeSequence, DTW dtw, PerformanceTime performanceTime) {
        this.degreeSequence = degreeSequence;
        this.dtw = dtw;
        this.performanceTime = performanceTime;
    }

    private void initArrays(Graph g) {
        sortedDegreeList = new Node[g.getNodeCount()];
        nodeIndexList = new int[g.getNodeCount()];
        Iterator<? extends Node> iterator = g.getEachNode().iterator();
        int i = 0;
        while(iterator.hasNext()) {
            Node node = iterator.next();
            sortedDegreeList[i] = node;
            i++;
        }
        Arrays.sort(sortedDegreeList, new Comparator<Node>() {
            @Override
            public int compare(Node o1, Node o2) {
                if (o1.getDegree() < o2.getDegree()){
                    return -1;
                }
                if(o1.getDegree() > o2.getDegree()) {
                    return 1;
                }
                return 0;
            }
        });
        for(i = 0; i < sortedDegreeList.length; i++) {
            Node node = sortedDegreeList[i];
            nodeIndexList[node.getIndex()] = i;
        }
    }

    Node getLeftElement(float division, int nodeIndex) {

        int i = nodeIndexList[nodeIndex];
        float aux = Float.parseFloat(i+"") / Float.parseFloat(division+"") * 1f;
        //LOGGER.info("Pegando elemento da esquerda - nodeIndex {} ,  novoIndex {} , divisor {}, i {}", nodeIndex, aux, division, i);
        if(aux > 0.5) {
            return sortedDegreeList[(int) aux];
        }
        //LOGGER.info("Retorno nulo - esquerda");
        return null;
    }

    Node getRightElement(float mult, int nodeIndex) {
        int i = nodeIndexList[nodeIndex];
        if(i == 0) {
            i++;
        }
        float aux = i * mult;
     //   LOGGER.info("Pegando elemento da direita - nodeIndex {} , novoIndex {}, multiplicador {}, i {}", nodeIndex, aux, mult, i);
        if(aux < sortedDegreeList.length) {
            return sortedDegreeList[(int) aux];
        }
       // LOGGER.info("Retorno nulo - direita");
        return null;
    }


    public Map<String, StructuralDistanceDto> execute2(Graph g, int maxDistance) {
        performanceTime.addStartTime("COMPLETE_STRUCTURAL_EXECUTION");
        initArrays(g);
        Map<String, StructuralDistanceDto>  strucDistHashMap = new HashMap<String, StructuralDistanceDto>();
        Iterator<? extends Node> node1Iterator = g.getEachNode().iterator();
        while(node1Iterator.hasNext()) {
            Node firstNode = node1Iterator.next();
            calStructuralDistanceExecution2(firstNode, g, maxDistance, 2f , strucDistHashMap);
           // calStructuralDistanceExecution2(firstNode, g, maxDistance, 3f , strucDistHashMap);
        }
        performanceTime.addTotalTime("COMPLETE_STRUCTURAL_EXECUTION");
        return strucDistHashMap;
    }

    void calStructuralDistanceExecution2(Node firstNode, Graph g, int maxDistance, float aux, Map<String, StructuralDistanceDto>  strucDistHashMap) {
        String node1 = firstNode.getId();
        Node rightNode = getRightElement(aux, firstNode.getIndex());
        Node leftNode = getLeftElement(aux, firstNode.getIndex());

        if(rightNode != null) {
            String rightNodeId = rightNode.getId();
            double distance = this.execute(g, node1, rightNodeId, maxDistance);
            StructuralDistanceDto dto = new StructuralDistanceDto(node1, rightNodeId, distance);
            strucDistHashMap.put(dto.getId(), dto);
        }
        if(leftNode != null) {
            String leftNodeId = leftNode.getId();
            double distance = this.execute(g, node1, leftNodeId, maxDistance);
            StructuralDistanceDto dto = new StructuralDistanceDto(node1, leftNodeId, distance);
            strucDistHashMap.put(dto.getId(), dto);
        }

        while (true) {
            aux = aux * 2;
            rightNode = getRightElement(aux, firstNode.getIndex());
            leftNode = getLeftElement(aux, firstNode.getIndex());
            if(rightNode != null) {
                String rightNodeId = rightNode.getId();
                double distance = this.execute(g, node1, rightNodeId, maxDistance);
                StructuralDistanceDto dto = new StructuralDistanceDto(node1, rightNodeId, distance);
                strucDistHashMap.put(dto.getId(), dto);
            }
            if(leftNode != null) {
                String leftNodeId = leftNode.getId();
                double distance = this.execute(g, node1, leftNodeId, maxDistance);
                StructuralDistanceDto dto = new StructuralDistanceDto(node1, leftNodeId, distance);
                strucDistHashMap.put(dto.getId(), dto);
            }
            if(rightNode == null && leftNode == null) {
                break;
            }
        }
    }

    public Map<String, StructuralDistanceDto> execute(Graph g, int maxDistance) {
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
                if(!node1.equals(node2) && !strucDistHashMap.containsKey(id)) {
                    double distance = this.execute(g, node1, node2, maxDistance);
                    StructuralDistanceDto dto = new StructuralDistanceDto(node1, node2, distance);
                    strucDistHashMap.put(dto.getId(), dto);
                }
             }

        }
        performanceTime.addTotalTime("COMPLETE_STRUCTURAL_EXECUTION");
        return strucDistHashMap;
    }

    double execute(Graph g, String node1, String node2, int maxDistance) {
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
