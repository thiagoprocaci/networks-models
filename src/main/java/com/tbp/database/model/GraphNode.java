package com.tbp.database.model;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import java.math.BigInteger;

@Entity
@Table(name = "graph_node")
public class GraphNode {

    @Id
    BigInteger id;
    @Column(name = "degree")
    Integer degree;

    public BigInteger getId() {
        return id;
    }

    public Integer getDegree() {
        return degree;
    }
}
