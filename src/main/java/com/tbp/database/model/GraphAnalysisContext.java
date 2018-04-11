package com.tbp.database.model;

import javax.persistence.*;


@Entity
@Table(name = "graph_analysis_context")
public class GraphAnalysisContext {
    @Id
    Long id;
    @Column(name = "period")
    Integer period;
    @Column(name = "id_community")
    Integer idCommunity;
    @Column(name = "nodes")
    Integer nodes;
    @Column(name = "edges")
    Integer edges;

    public Integer getEdges() {
        return edges;
    }

    public Integer getPeriod() {
        return period;
    }

    public Integer getIdCommunity() {
        return idCommunity;
    }

    public Integer getNodes() {
        return nodes;
    }

    public Long getId() {
        return id;
    }
}
