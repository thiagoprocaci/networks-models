package com.tbp.network;


import java.util.HashMap;
import java.util.Map;

public class Graph {

    Map<String,Edge> edges;
    Map<String, Node> nodes;


    public Graph() {
        this.edges = new HashMap<String, Edge>();
        this.nodes = new HashMap<String, Node>();
    }


    public Edge addEdge(String sourceNodeId, String destNodeId) {
        Node source = addNode(sourceNodeId);
        Node dest = addNode(destNodeId);
        String edgeId = Edge.genId(source, dest);
        Edge edge = edges.get(edgeId);
        if(edge == null) {
            edge = new Edge(source, dest);
            this.edges.put(edgeId, edge);
        } else {
            edge.increaseWeight();
        }
        return edge;
    }


    public Node addNode(String nodeId) {
        Node n = nodes.get(nodeId);
        if(n == null) {
            n = new Node(nodeId);
            nodes.put(n.getId(), n);
        }
        return n;
    }

    public Map<String, Edge> getEdges() {
        return edges;
    }

    public Map<String, Node> getNodes() {
        return nodes;
    }
}
