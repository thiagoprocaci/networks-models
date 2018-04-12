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


    public StructDistance(BigInteger node1, BigInteger node2, StructAnalysisContext structAnalysisContext) {
        this.node1 = node1;
        this.node2 = node2;
        this.structAnalysisContext = structAnalysisContext;
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
}
