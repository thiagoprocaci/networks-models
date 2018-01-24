package com.tbp.network.model;




import org.graphstream.graph.EdgeRejectedException;
import org.graphstream.graph.Graph;
import org.graphstream.graph.IdAlreadyInUseException;
import org.graphstream.graph.implementations.SingleGraph;

import java.util.Random;

public class ErdosRenyi {

    Double probability;
    Integer numNodes;
    Integer numEdges;

    public ErdosRenyi(Integer numNodes, Integer numEdges, Double probability) {
        if(numEdges == null || numNodes == null || probability == null) {
            throw new IllegalArgumentException("Params can not be null");
        }
        if(numEdges < 1 || numNodes < 1) {
            throw new IllegalArgumentException("numNodes and numEdges must be > 0");
        }
        if(probability < 0d || probability > 1) {
            throw new IllegalArgumentException("Probability out of range 0 < prob < 1 ");
        }
        this.probability = probability;
        this.numNodes = numNodes;
        this.numEdges = numEdges;
    }

    public Graph generate() {
        Graph g = new SingleGraph("Erdos Renyi");
        Random random = new Random();
        for(int i = 0; i < numNodes; i++) {
            g.addNode(i+"");
        }
        int count = 0;
        while(count < numEdges) {
            Integer source = random.nextInt(numNodes);
            Integer dest = random.nextInt(numNodes);
            // avoid self edge
            while(source == dest) {
                dest = random.nextInt(numNodes);
            }
            try {
                g.addEdge(source.toString() +"_"+ dest.toString(),source.toString(), dest.toString());
                count++;
            } catch (EdgeRejectedException e) {

            } catch (IdAlreadyInUseException e) {

            }

        }
        g.display();
        return g;
    }

}
