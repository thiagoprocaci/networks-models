package com.tbp.network.model;


import org.apache.commons.math.stat.descriptive.DescriptiveStatistics;
import org.graphstream.graph.Graph;
import org.graphstream.graph.Node;

import java.util.Collection;
import java.util.Random;

public abstract class NetworkModel {

    Integer numNodes;
    Random random;
    DescriptiveStatistics descriptiveStatistics;
    Graph graph;

    double minDegree;
    double firstQuDegree;
    double medianDegree;
    double meanDegree;
    double thirdQuDegree;
    double maxDegree;


    public NetworkModel(Integer numNodes) {
        if(numNodes == null || numNodes < 10) {
            throw new IllegalArgumentException("Number of nodes must be >= 10");
        }
        this.random = new Random();
        this.numNodes = numNodes;
        this.graph = generate();
        this.descriptiveStatistics = new DescriptiveStatistics();
        this.summaryDegree();
        this.setStyle();
    //    this.graph.display();
    }

    double nextDouble() {
        double start = 0;
        double end = 1;
        double randomNumber = this.random.nextDouble();
        double result = start + (randomNumber * (end - start));
        return result;
    }

    void summaryDegree() {
        Collection<Node> nodeSet = graph.getNodeSet();
        for(Node n: nodeSet) {
            descriptiveStatistics.addValue(n.getDegree());
        }
        minDegree = descriptiveStatistics.getMin();
        firstQuDegree = descriptiveStatistics.getPercentile(25);
        medianDegree = descriptiveStatistics.getPercentile(50);
        meanDegree = descriptiveStatistics.getMean();
        thirdQuDegree = descriptiveStatistics.getPercentile(75);
        maxDegree = descriptiveStatistics.getMax();
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
            if(n.getDegree() > medianDegree) {
                colour = "green";
                size = "5";
            }
            if(n.getDegree() > thirdQuDegree) {
                colour = "blue";
                size = "7";
            }
            if(n.getDegree() > 2 * thirdQuDegree) {
                colour = "purple";
                size = "10";
            }
            if(n.getDegree() > 10 * thirdQuDegree) {
                colour = "brown";
                size = "14";
            }
            if(n.getDegree() > 20 * thirdQuDegree) {
                colour = "red";
                size = "18";
            }
            n.addAttribute("ui.style", String.format(style, size, colour));
        }
    }


    @Override
    public String toString() {
        return "NetworkModel{" +
                "minDegree=" + minDegree +
                ", firstQuDegree=" + firstQuDegree +
                ", medianDegree=" + medianDegree +
                ", meanDegree=" + meanDegree +
                ", thirdQuDegree=" + thirdQuDegree +
                ", maxDegree=" + maxDegree +
                '}';
    }

    abstract Graph generate();

    public Graph getGraph() {
        return graph;
    }
}
