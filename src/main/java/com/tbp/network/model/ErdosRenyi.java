package com.tbp.network.model;

import com.tbp.network.performance.PerformanceTime;
import org.graphstream.graph.Graph;
import org.graphstream.graph.Node;
import org.graphstream.graph.implementations.SingleGraph;



public class ErdosRenyi extends NetworkModel {

    public ErdosRenyi(Integer numNodes, PerformanceTime performanceTime) {
        super(numNodes, performanceTime);
    }

    @Override
    Graph generate() {
        Graph g = new SingleGraph("Erdos-Renyi model");
        // adding the first nodes
        g.addNode("0");
        g.addNode("1");
        // creates the first edge
        g.addEdge("0_1", "0", "1");
        Integer i = 2;
        while(i < numNodes) {
            Node source = g.addNode(i.toString());
            Node dest = g.getNode(random.nextInt(i)+"");
            g.addEdge(source.getId() + "_" + dest.getId(), source.getId(), dest.getId());
            i++;
        }
        return g;
    }

    @Override
    String modelName() {
        return "erdosRenyi_growth_model";
    }

}
