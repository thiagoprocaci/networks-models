package com.tbp.network.structure;


import com.tbp.network.model.NetworkModel;
import com.tbp.network.performance.PerformanceTime;
import com.tbp.network.structure.degreeseq.DegreeSequence;
import com.tbp.network.structure.dtw.DTW;
import com.tbp.network.structure.model.StructuralDistanceDto;
import org.graphstream.graph.Graph;
import org.graphstream.graph.Node;

import java.util.*;

public class PartialStructuralDistance extends StructuralDistance {

    Node[] sortedDegreeList;
    int[] nodeIndexList;

    public PartialStructuralDistance(DegreeSequence degreeSequence, DTW dtw, PerformanceTime performanceTime) {
        super(degreeSequence, dtw, performanceTime);
    }


    @Override
    public Map<String, StructuralDistanceDto> execute(NetworkModel model, int maxDistance) {
        Graph g = model.getGraph();
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
            double distance = this.dtwBetweenNodes(g, node1, rightNodeId, maxDistance);
            StructuralDistanceDto dto = new StructuralDistanceDto(node1, rightNodeId, distance);
            strucDistHashMap.put(dto.getId(), dto);
        }
        if(leftNode != null) {
            String leftNodeId = leftNode.getId();
            double distance = this.dtwBetweenNodes(g, node1, leftNodeId, maxDistance);
            StructuralDistanceDto dto = new StructuralDistanceDto(node1, leftNodeId, distance);
            strucDistHashMap.put(dto.getId(), dto);
        }

        while (true) {
            aux = aux * 2;
            rightNode = getRightElement(aux, firstNode.getIndex());
            leftNode = getLeftElement(aux, firstNode.getIndex());
            if(rightNode != null) {
                String rightNodeId = rightNode.getId();
                double distance = this.dtwBetweenNodes(g, node1, rightNodeId, maxDistance);
                StructuralDistanceDto dto = new StructuralDistanceDto(node1, rightNodeId, distance);
                strucDistHashMap.put(dto.getId(), dto);
            }
            if(leftNode != null) {
                String leftNodeId = leftNode.getId();
                double distance = this.dtwBetweenNodes(g, node1, leftNodeId, maxDistance);
                StructuralDistanceDto dto = new StructuralDistanceDto(node1, leftNodeId, distance);
                strucDistHashMap.put(dto.getId(), dto);
            }
            if(rightNode == null && leftNode == null) {
                break;
            }
        }
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
}
