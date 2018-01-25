package com.tbp.network.model;


import org.graphstream.graph.Graph;
import org.graphstream.graph.Node;
import org.graphstream.graph.implementations.SingleGraph;

import java.util.Random;

public class BarabasiModel {

    Integer numNodes;

    public BarabasiModel(Integer numNodes) {
        if(numNodes == null || numNodes < 10) {
            throw new IllegalArgumentException("Number of nodes must be >= 10");
        }
        this.numNodes = numNodes;
    }


    public Graph generate() {
        Random random = new Random();
        Graph g = new SingleGraph("Barabasi–Albert model");

        // adicionando o primeiro no
        g.addNode("0");
        g.addNode("1");
        // creates the first edge
        g.addEdge("0_1", "0", "1");

        int sumDegree = 2;
        Integer i = 2;
        while(i < numNodes) {
            Node source = g.getNode(i.toString());
            if(source == null) {
                source = g.addNode(i.toString());
            }
            Node dest = g.getNode(random.nextInt(i)+"");
            double probability = dest.getDegree() * 1.0/sumDegree;
            double r = nextDouble();
            if(probability > r) {
                g.addEdge(source.getId() + "_" + dest.getId(), source.getId(), dest.getId());
                sumDegree = sumDegree + 2;
                i++;
            }
        }
        g.display();
        return g;
    }


    double nextDouble() {
        double start = 0;
        double end = 1;
        double random = new Random().nextDouble();
        double result = start + (random * (end - start));
        return result;
    }




}
