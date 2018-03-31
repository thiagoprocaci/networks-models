package com.tbp.network.model;

import com.tbp.network.structure.model.NodesStrucDist;
import org.apache.commons.math.stat.descriptive.DescriptiveStatistics;

import org.graphstream.graph.*;
import org.graphstream.graph.implementations.SingleGraph;

import java.util.*;


public class RegenerateModel  {

    Random random;
    DescriptiveStatistics descriptiveStatistics;
    Graph graph;

    double minSS;
    double firstQuSS;
    double medianSS;
    double meanSS;
    double thirdQuSS;
    double maxSS;


    public RegenerateModel(Graph oldGraph, Map<String, NodesStrucDist> nodesStrucDistMap) {
        this.random = new Random();
        this.graph = generate(oldGraph, nodesStrucDistMap);
        this.descriptiveStatistics = new DescriptiveStatistics();
        this.summaryPreviousDegree();
        this.setStyle();
    }

    Graph generate(Graph oldGraph, Map<String, NodesStrucDist> nodesStrucDistMap) {
        Graph g = new SingleGraph("Regenerated model based on structural distance");
        DescriptiveStatistics d = describeDistances(nodesStrucDistMap);
        Iterator<? extends Node> node1Iterator = oldGraph.getEachNode().iterator();
        while(node1Iterator.hasNext()) {
            Node firstNode = node1Iterator.next();
            String nodeId1 = firstNode.getId();
            Iterator<? extends Node> node2Iterator = oldGraph.getEachNode().iterator();
            while(node2Iterator.hasNext()) {
                Node secondNode = node2Iterator.next();
                String nodeId2 = secondNode.getId();
                if(nodeId1.equals(nodeId2)) {
                    continue;
                }
                Double distance = nodesStrucDistMap.get(NodesStrucDist.generateId(nodeId1, nodeId2)).getStructDistance();
                try {
                    Node node = g.addNode(nodeId1);
                    node.addAttribute("PREVIOUS_DEGREE", oldGraph.getNode(nodeId1).getDegree());
                } catch (IdAlreadyInUseException e) {
                }
                try {
                    Node node = g.addNode(nodeId2);
                    node.addAttribute("PREVIOUS_DEGREE", oldGraph.getNode(nodeId2).getDegree());
                } catch (IdAlreadyInUseException e) {
                }
                 if(distance < d.getPercentile(25)) {
                    try {
                        g.addEdge(nodeId1 + "_" + nodeId2, nodeId1, nodeId2);
                    } catch (IdAlreadyInUseException | EdgeRejectedException e) {
                       // e.printStackTrace();
                    }
                }
            }
        }
        return  g;
    }

    DescriptiveStatistics describeDistances(Map<String, NodesStrucDist> nodesStrucDistMap) {
        double sum = 0;
        DescriptiveStatistics d = new DescriptiveStatistics();
        for(NodesStrucDist n: nodesStrucDistMap.values()) {
            d.addValue(n.getStructDistance());
        }
        return d;
    }

    double nextDouble() {
        double start = 0;
        double end = 1;
        double randomNumber = this.random.nextDouble();
        double result = start + (randomNumber * (end - start));
        return result;
    }

    void summaryPreviousDegree() {
        Collection<Node> edgeSet = graph.getNodeSet();
        for(Node n: edgeSet) {
            descriptiveStatistics.addValue((Integer) n.getAttribute("PREVIOUS_DEGREE"));
        }
        minSS = descriptiveStatistics.getMin();
        firstQuSS = descriptiveStatistics.getPercentile(25);
        medianSS = descriptiveStatistics.getPercentile(50);
        meanSS = descriptiveStatistics.getMean();
        thirdQuSS = descriptiveStatistics.getPercentile(75);
        maxSS = descriptiveStatistics.getMax();
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
            Integer ss = n.getAttribute("PREVIOUS_DEGREE");
            if(ss > medianSS) {
                colour = "green";
                size = "5";
            }
            if(ss > thirdQuSS) {
                colour = "blue";
                size = "7";
            }
            if(ss > 2 * thirdQuSS) {
                colour = "purple";
                size = "10";
            }
            if(ss > 10 * thirdQuSS) {
                colour = "brown";
                size = "14";
            }
            if(ss > 20 * thirdQuSS) {
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
