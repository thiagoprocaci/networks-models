package com.tbp.network.structure.model;


import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class NodesStrucDist {

    String id;
    String node1;
    String node2;
    Double structDistance;


    public NodesStrucDist(String node1, String node2, Double structDistance) {
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

    public Double getStructDistance() {
        return structDistance;
    }

    public String getId() {
        return id;
    }
}
