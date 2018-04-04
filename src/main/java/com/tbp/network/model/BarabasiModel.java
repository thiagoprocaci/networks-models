package com.tbp.network.model;


import com.tbp.network.performance.PerformanceTime;
import org.graphstream.graph.Graph;
import org.graphstream.graph.Node;
import org.graphstream.graph.implementations.SingleGraph;


public class BarabasiModel extends NetworkModel {


    public BarabasiModel(Integer numNodes, PerformanceTime performanceTime) {
        super(numNodes, performanceTime);
    }

    @Override
    Graph generate() {
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
        return g;
    }

    @Override
    String modelName() {
        return "barabasi_growth_model";
    }


}
