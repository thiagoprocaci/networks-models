package com.tbp.database.model;

import javax.persistence.*;

@Entity
@Table(name = "minimum_spanning_tree")
public class MST {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "minimum_spanning_tree_seq")
    @SequenceGenerator(name="minimum_spanning_tree_seq", sequenceName = "minimum_spanning_tree_seq", allocationSize = 1)
    Long id;
    @ManyToOne
    @JoinColumn(name = "id_community")
    Community community;
    @ManyToOne
    @JoinColumn(name = "id_struct_analysis_context")
    StructAnalysisContext structAnalysisContext;
    @ManyToOne
    @JoinColumn(name = "id_graph_analysis_context")
    GraphAnalysisContext graphAnalysisContext;
    @Column(name = "nodes")
    Integer nodes;
    @Column(name = "edges")
    Integer edges;


    public MST() {

    }

    public MST(Community community, StructAnalysisContext structAnalysisContext, GraphAnalysisContext graphAnalysisContext, Integer nodes, Integer edges) {
        this.community = community;
        this.structAnalysisContext = structAnalysisContext;
        this.graphAnalysisContext = graphAnalysisContext;
        this.nodes = nodes;
        this.edges = edges;
    }

    public Long getId() {
        return id;
    }

    public Community getCommunity() {
        return community;
    }

    public StructAnalysisContext getStructAnalysisContext() {
        return structAnalysisContext;
    }

    public GraphAnalysisContext getGraphAnalysisContext() {
        return graphAnalysisContext;
    }

    public Integer getNodes() {
        return nodes;
    }

    public Integer getEdges() {
        return edges;
    }
}
