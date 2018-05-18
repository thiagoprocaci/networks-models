package com.tbp.network.model.regenerate;

import org.apache.commons.math.stat.descriptive.DescriptiveStatistics;
import org.graphstream.graph.Graph;
import org.graphstream.graph.Node;

import java.util.Collection;


public abstract class RegenerateModel {

    static final String PREVIOUS_DEGREE = "PREVIOUS_DEGREE";
    DescriptiveStatistics descriptiveStatistics;
    Graph graph;

    double minPreviousDegree;
    double firstQuPreviousDegree;
    double medianPreviousDegree;
    double meanPreviousDegree;
    double thirdQuPreviousDegree;
    double maxPreviousDegree;

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
