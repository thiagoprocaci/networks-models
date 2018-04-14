package com.tbp.database.service;


import com.tbp.database.model.GraphAnalysisContext;
import com.tbp.database.model.GraphEdge;
import com.tbp.database.repository.GraphAnalysisContextRepository;
import com.tbp.database.repository.GraphEdgeRepository;
import com.tbp.network.structure.model.StructuralDistanceDto;
import org.graphstream.graph.Edge;
import org.graphstream.graph.Graph;
import org.graphstream.graph.Node;
import org.graphstream.graph.implementations.SingleGraph;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class GraphService {

    @Autowired
    GraphAnalysisContextRepository graphAnalysisContextRepository;
    @Autowired
    GraphEdgeRepository graphEdgeRepository;

    public Graph loadFromDatabase(String communityName) {
        GraphAnalysisContext latest = graphAnalysisContextRepository.getLatest(communityName);
        List<GraphEdge> graphEdgeList = graphEdgeRepository.findByGraphAnalysisContext(latest);
        Graph g = new SingleGraph(communityName);
        for(GraphEdge edge: graphEdgeList) {
            Node source  = addNode(g, edge.getNodeSource().toString());
            Node dest = addNode(g, edge.getNodeDest().toString());
            String edgeId = StructuralDistanceDto.generateId(source.getId(), dest.getId());
            addEdge(g, edgeId, source, dest);
        }
        return g;
    }


    Node addNode(Graph g, String id) {
        Node node = g.getNode(id);
        if(node != null) {
            return node;
        }
        return g.addNode(id);
    }

    void addEdge(Graph g, String edgeId, Node source, Node dest) {
        Edge edge = g.getEdge(edgeId);
        if(edge == null) {
            g.addEdge(edgeId, source, dest);
        }
    }
}
