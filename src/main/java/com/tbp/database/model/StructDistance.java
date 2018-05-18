package com.tbp.database.model;

import javax.persistence.*;
import java.math.BigInteger;

@Entity
@Table(name = "struct_distance")
public class StructDistance {
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "struct_distance_seq")
    @SequenceGenerator(name="struct_distance_seq", sequenceName = "struct_distance_seq", allocationSize = 1)
    BigInteger id;
    @Column(name = "node1")
    BigInteger node1;
    @Column(name = "node2")
    BigInteger node2;
    @ManyToOne
    @JoinColumn(name = "id_struct_analysis_context")
    StructAnalysisContext structAnalysisContext;

    @Column(name = "distance_custom_dtw_0")
    Double distance0;
    @Column(name = "distance_custom_dtw_1", updatable = false)
    Double distance1;
    @Column(name = "distance_custom_dtw_2")
    Double distance2;

    public StructDistance(BigInteger node1, BigInteger node2, StructAnalysisContext structAnalysisContext) {
        this.node1 = node1;
        this.node2 = node2;
        this.structAnalysisContext = structAnalysisContext;
    }

    public StructDistance() {
    }

    public BigInteger getId() {
        return id;
    }

    public BigInteger getNode1() {
        return node1;
    }

    public BigInteger getNode2() {
        return node2;
    }

    public StructAnalysisContext getStructAnalysisContext() {
        return structAnalysisContext;
    }

    public Double getDistance0() {
        return distance0;
    }

    public void setDistance0(Double distance0) {
        this.distance0 = distance0;
    }

    public Double getDistance1() {
        return distance1;
    }

    public void setDistance1(Double distance1) {
        this.distance1 = distance1;
    }

    public Double getDistance2() {
        return distance2;
    }

    public void setDistance2(Double distance2) {
        this.distance2 = distance2;
    }
}
