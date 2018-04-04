package com.tbp.network.model;

import com.tbp.network.mst.KruskalMST;
import com.tbp.network.mst.KruskalQuickFind;
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
        this.graph = generate(oldGraph, nodesStrucDistMap);
        this.descriptiveStatistics = new DescriptiveStatistics();
        this.summaryPreviousDegree();
        this.setStyle();
    }


    Graph generate(Graph oldGraph, Map<String, StructuralDistanceDto> dtoMap) {
        KruskalMST kruskalMST = new KruskalQuickFind();
        kruskalMST.run(dtoMap, oldGraph);
        Graph g = new SingleGraph("Regenerated model based on structural distance");

        Iterable<StructuralDistanceDto> edges = kruskalMST.edges();
        Iterator<StructuralDistanceDto> iterator = edges.iterator();
        while(iterator.hasNext()) {
            StructuralDistanceDto next = iterator.next();
            if(g.getNode(next.getNode1()) == null) {
                Node newNode = g.addNode(next.getNode1());
                newNode.addAttribute(PREVIOUS_DEGREE, oldGraph.getNode(next.getNode1()).getDegree());
            }
            if(g.getNode(next.getNode2()) == null) {
                Node newNode = g.addNode(next.getNode2());
                newNode.addAttribute(PREVIOUS_DEGREE, oldGraph.getNode(next.getNode2()).getDegree());
            }
            try {
                g.addEdge(next.getNode1() + "_" + next.getNode2(), next.getNode1(), next.getNode2());
            } catch (IdAlreadyInUseException | EdgeRejectedException e) {
                // LOGGER.warn(e.getMessage());
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
