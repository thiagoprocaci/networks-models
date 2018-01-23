package com.tbp.network;


public class Node extends Entity<String> {

    String id;

    public Node(String id) {
        if(id == null || id.trim().length() == 0) {
            throw new IllegalArgumentException("Node id null or empty");
        }
        this.id = id;
    }


    public String getId() {
        return id;
    }
}
