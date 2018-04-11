package com.tbp.database.model;

import javax.persistence.*;

@Entity
@Table(name = "graph_edge")
public class GraphEdge {
    @Id
    Long id;
    @Column(name = "id_graph_node_source")
    Long nodeSource;
    @Column(name = "id_graph_node_dest")
    Long nodeDest;
    @ManyToOne
    @JoinColumn(name = "id_graph_analysis_context")
    GraphAnalysisContext graphAnalysisContext;

    public Long getId() {
        return id;
    }

    public Long getNodeSource() {
        return nodeSource;
    }

    public Long getNodeDest() {
        return nodeDest;
    }

    public GraphAnalysisContext getGraphAnalysisContext() {
        return graphAnalysisContext;
    }
}
