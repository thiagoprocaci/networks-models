package com.tbp.database.model;

import javax.persistence.*;
import java.math.BigInteger;

@Entity
@Table(name = "graph_node")
public class GraphNode {

    @Id
    Long id;
    @Column(name = "degree")
    Integer degree;
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "id_user")
    User user;

    public Long getId() {
        return id;
    }

    public Integer getDegree() {
        return degree;
    }

    public User getUser() {
        return user;
    }
}
