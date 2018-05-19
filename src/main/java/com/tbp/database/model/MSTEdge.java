package com.tbp.database.model;



import javax.persistence.*;


@Entity
@Table(name = "minimum_spanning_tree_edge")
public class MSTEdge {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "minimum_spanning_tree_edge_seq")
    @SequenceGenerator(name="minimum_spanning_tree_edge_seq", sequenceName = "minimum_spanning_tree_edge_seq", allocationSize = 1)
    Long id;
    @ManyToOne
    @JoinColumn(name = "id_graph_node_source")
    GraphNode graphNodeSource;
    @ManyToOne
    @JoinColumn(name = "id_graph_node_dest")
    GraphNode graphNodeDest;
    @ManyToOne
    @JoinColumn(name = "id_user_source")
    User userSource;
    @ManyToOne
    @JoinColumn(name = "id_user_dest")
    User userDest;
    @ManyToOne
    @JoinColumn(name = "id_community")
    Community community;
    @ManyToOne
    @JoinColumn(name = "id_struct_analysis_context")
    StructAnalysisContext structAnalysisContext;
    @ManyToOne
    @JoinColumn(name = "id_graph_analysis_context")
    GraphAnalysisContext graphAnalysisContext;
    @Column(name = "weight")
    Double weight;
    @ManyToOne
    @JoinColumn(name = "id_minimum_spanning_tree")
    MST mst;

    public MSTEdge() {}

    public MSTEdge(GraphNode graphNodeSource, GraphNode graphNodeDest, User userSource, User userDest, Community community, StructAnalysisContext structAnalysisContext, GraphAnalysisContext graphAnalysisContext, Double weight, MST mst) {
        this.graphNodeSource = graphNodeSource;
        this.graphNodeDest = graphNodeDest;
        this.userSource = userSource;
        this.userDest = userDest;
        this.community = community;
        this.structAnalysisContext = structAnalysisContext;
        this.graphAnalysisContext = graphAnalysisContext;
        this.weight = weight;
        this.mst = mst;
    }

    public Long getId() {
        return id;
    }

    public GraphNode getGraphNodeSource() {
        return graphNodeSource;
    }

    public GraphNode getGraphNodeDest() {
        return graphNodeDest;
    }

    public User getUserSource() {
        return userSource;
    }

    public User getUserDest() {
        return userDest;
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

    public Double getWeight() {
        return weight;
    }

    public MST getMst() {
        return mst;
    }
}
