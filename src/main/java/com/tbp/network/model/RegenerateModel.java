package com.tbp.network.model;

import com.tbp.network.structure.model.StructuralDistanceDto;
import org.apache.commons.math.stat.descriptive.DescriptiveStatistics;

import org.graphstream.graph.*;
import org.graphstream.graph.implementations.SingleGraph;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.*;


public class RegenerateModel  {

    private static final Logger LOGGER = LoggerFactory.getLogger(RegenerateModel.class);
    static final String PREVIOUS_DEGREE = "PREVIOUS_DEGREE";
    Random random;
    DescriptiveStatistics descriptiveStatistics;
    Graph graph;

    double minPreviousDegree;
    double firstQuPreviousDegree;
    double medianPreviousDegree;
    double meanPreviousDegree;
    double thirdQuPreviousDegree;
    double maxPreviousDegree;



    public RegenerateModel(Graph oldGraph, Map<String, StructuralDistanceDto> nodesStrucDistMap) {
        this.random = new Random();
        this.graph = generate2(oldGraph, nodesStrucDistMap);
        this.descriptiveStatistics = new DescriptiveStatistics();
        this.summaryPreviousDegree();
        this.setStyle();
    }

    Graph createNewGraphWithNodeOf(Graph oldGraph) {
        Graph g = new SingleGraph("Regenerated model based on structural distance");
        Iterator<? extends Node> nodeIterator = oldGraph.getEachNode().iterator();
        while(nodeIterator.hasNext()) {
            Node node = nodeIterator.next();
            Node newNode = g.addNode(node.getId());
            newNode.addAttribute(PREVIOUS_DEGREE, node.getDegree());
        }
        return g;
    }


    Graph generate2(Graph oldGraph, Map<String, StructuralDistanceDto> dtoMap) {
        Graph g =  createNewGraphWithNodeOf(oldGraph);
        DescriptiveStatistics d = describeDistances(dtoMap);
        Integer totalNodes = oldGraph.getNodeCount();

        int index = 0;
        int totalIterations = totalNodes * 10;
        int iterationWithoutConnections = 0;
        while(index < totalIterations) {
            int node1 = random.nextInt(totalNodes);
            int node2 = random.nextInt(totalNodes);
            while(node1 == node2) {
                node2 = random.nextInt(totalNodes);
            }
            String nodeId1 = g.getNode(node1).getId();
            String nodeId2 = g.getNode(node2).getId();
            Double distance = dtoMap.get(StructuralDistanceDto.generateId(nodeId1, nodeId2)).getStructDistance();
            iterationWithoutConnections++;
            if(distance < d.getPercentile(25)) {
                try {
                    g.addEdge(nodeId1 + "_" + nodeId2, nodeId1, nodeId2);
                    index++;
                    iterationWithoutConnections = 0;
                } catch (IdAlreadyInUseException | EdgeRejectedException e) {
                   // LOGGER.warn(e.getMessage());
                }
            }
            if(iterationWithoutConnections == 1000) {
                LOGGER.warn("The model seems to be stuck");
            }

        }
        return g;
    }

    DescriptiveStatistics describeDistances(Map<String, StructuralDistanceDto> nodesStrucDistMap) {
        DescriptiveStatistics d = new DescriptiveStatistics();
        for(StructuralDistanceDto n: nodesStrucDistMap.values()) {
            d.addValue(n.getStructDistance());
        }
        return d;
    }

    void summaryPreviousDegree() {
        Collection<Node> edgeSet = graph.getNodeSet();
        for(Node n: edgeSet) {
            descriptiveStatistics.addValue((Integer) n.getAttribute(PREVIOUS_DEGREE));
        }
        minPreviousDegree = descriptiveStatistics.getMin();
        firstQuPreviousDegree = descriptiveStatistics.getPercentile(25);
        medianPreviousDegree = descriptiveStatistics.getPercentile(50);
        meanPreviousDegree = descriptiveStatistics.getMean();
        thirdQuPreviousDegree = descriptiveStatistics.getPercentile(75);
        maxPreviousDegree = descriptiveStatistics.getMax();
        //   System.out.println(toString());
    }

    void setStyle() {
        String style = "size: %spx ; fill-color: %s;";
        Collection<Node> nodeSet = graph.getNodeSet();
        String colour;
        String size;
        for(Node n: nodeSet) {
            colour = "black";
            size = "3";
            Integer previousDegree = n.getAttribute(PREVIOUS_DEGREE);
            if(previousDegree > medianPreviousDegree) {
                colour = "green";
                size = "5";
            }
            if(previousDegree > thirdQuPreviousDegree) {
                colour = "blue";
                size = "7";
            }
            if(previousDegree > 2 * thirdQuPreviousDegree) {
                colour = "purple";
                size = "10";
            }
            if(previousDegree > 10 * thirdQuPreviousDegree) {
                colour = "brown";
                size = "14";
            }
            if(previousDegree > 20 * thirdQuPreviousDegree) {
                colour = "red";
                size = "18";
            }
            n.addAttribute("ui.style", String.format(style, size, colour));
        }
    }

    public Graph getGraph() {
        return graph;
    }
}
