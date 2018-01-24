package com.tbp.network;


public class Node extends Entity<String> {

    String id;
    Integer indegree;
    Integer outdegree;

    public Node(String id) {
        if(id == null || id.trim().length() == 0) {
            throw new IllegalArgumentException("Node id null or empty");
        }
        this.id = id;
        this.indegree = 0;
        this.outdegree = 0;
    }

    public String getId() {
        return id;
    }

    public Integer getIndegree() {
        return indegree;
    }

    public Integer getOutdegree() {
        return outdegree;
    }

    public void increaseIndegree() {
        indegree++;
    }

    public void increaseOutdegree() {
        outdegree++;
    }
}
