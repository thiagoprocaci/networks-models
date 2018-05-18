package com.tbp.network.structure.model;


import com.tbp.network.mst.support.ComparableEdge;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Dto that stores the structural distance between two nodes
 */
public class StructuralDistanceDto implements ComparableEdge<StructuralDistanceDto> {

    String id; // id of the dto
    String node1;
    String node2;
    Double structDistance;


    /**
     *
     * @param node1 id of the first node
     * @param node2 id of the second node
     * @param structDistance structutal distance
     */
    public StructuralDistanceDto(String node1, String node2, Double structDistance) {
        this.node1 = node1;
        this.node2 = node2;
        this.structDistance = structDistance;
        this.id = generateId(node1, node2);
    }

    public static String generateId(String node1, String node2) {
        List<String> list = new ArrayList<String>(2);
        list.add(node1);
        list.add(node2);
        Collections.sort(list);
        return list.get(0) + "_" + list.get(1);
    }

    public String getNode1() {
        return node1;
    }

    public String getNode2() {
        return node2;
    }

    @Override
    public Integer getNode() {
        return Integer.parseInt(node1);
    }

    @Override
    public Integer getOtherNode() {
        return Integer.parseInt(node2);
    }

    @Override
    public double getDistance() {
        return getStructDistance();
    }

    public Double getStructDistance() {
        return structDistance;
    }

    public String getId() {
        return id;
    }

    @Override
    public int compareTo(StructuralDistanceDto o) {
        if (this.getStructDistance() < o.getStructDistance()){
            return -1;
        }
        if (this.getStructDistance() > o.getStructDistance()) {
            return 1;
        }
        return 0;
    }
}
