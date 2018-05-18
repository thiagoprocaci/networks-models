package com.tbp.database.model.view;


import javax.persistence.*;
import java.math.BigInteger;

@Entity
@Table(name = "biology_struct_distance_custom_dtw_1")
public class BiologyStructDistanceCustomDtw1 implements ViewStructDistance<BiologyStructDistanceCustomDtw1> {
    @Id
    BigInteger id;
    @Column(name = "node1")
    BigInteger node1;
    @Column(name = "node2")
    BigInteger node2;
    @Column(name = "distance_custom_dtw_1", updatable = false)
    Double distance1;
    @Column(name = "node1_degree")
    Integer degreeNode1;
    @Column(name = "node2_degree")
    Integer degreeNode2;

    @Column(name = "node1_alternative_id")
    Integer node1AlternativeId;
    @Column(name = "node2_alternative_id")
    Integer node2AlternativaId;

    public BigInteger getId() {
        return id;
    }

    @Override
    public Integer getNode() {
        return node1AlternativeId;
    }

    @Override
    public Integer getOtherNode() {
        return node2AlternativaId;
    }

    @Override
    public double getDistance() {
        return distance1;
    }

    @Override
    public Integer getDegreeNode1() {
        return degreeNode1;
    }

    @Override
    public Integer getDegreeNode2() {
        return degreeNode2;
    }

    public BigInteger getNode1() {
        return node1;
    }

    public BigInteger getNode2() {
        return node2;
    }


    @Override
    public int compareTo(BiologyStructDistanceCustomDtw1 o) {
        if (this.getDistance() < o.getDistance()){
            return -1;
        }
        if (this.getDistance() > o.getDistance()) {
            return 1;
        }
        return 0;
    }

}
