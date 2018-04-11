package com.tbp.database.model;


import javax.persistence.*;

@Entity
@Table(name = "struct_analysis_context")
public class StructAnalysisContext {
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "struct_analysis_context_seq")
    @SequenceGenerator(name="struct_analysis_context_seq", sequenceName = "struct_analysis_context_seq", allocationSize = 1)
    Long id;
    @Column(name = "max_distance")
    Long maxDistance;
    @ManyToOne
    @JoinColumn(name = "id_graph_analysis_context")
    GraphAnalysisContext graphAnalysisContext;
    @Column(name = "description")
    String description;

    public StructAnalysisContext(Long maxDistance, GraphAnalysisContext graphAnalysisContext, String description) {
        this.maxDistance = maxDistance;
        this.graphAnalysisContext = graphAnalysisContext;
        this.description = description;
    }

    public Long getId() {
        return id;
    }

    public Long getMaxDistance() {
        return maxDistance;
    }

    public GraphAnalysisContext getGraphAnalysisContext() {
        return graphAnalysisContext;
    }

    public String getDescription() {
        return description;
    }
}