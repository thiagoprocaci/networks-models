package com.tbp.network.model;


import org.graphstream.graph.EdgeRejectedException;
import org.graphstream.graph.Graph;
import org.graphstream.graph.IdAlreadyInUseException;
import org.graphstream.graph.Node;
import org.graphstream.graph.implementations.SingleGraph;

import java.util.Random;

public class ErdosRenyi {

    Integer numNodes;;

    public ErdosRenyi(Integer numNodes) {
        this.numNodes = numNodes;
    }

    public Graph generate() {
        Random random = new Random();
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
        g.display();
        return g;
    }

}
