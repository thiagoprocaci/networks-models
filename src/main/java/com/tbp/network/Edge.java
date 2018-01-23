package com.tbp.network;


public class Edge extends Entity<String> {

    String id;
    Node source;
    Node dest;
    Integer weight;

    public Edge(Node source, Node dest) {
        this.weight = 1;
        this.source = source;
        this.dest = dest;
        this.id = genId(this.source, this.dest);
    }

    public void increaseWeight() {
        this.weight++;
    }


    public String getId() {
        return id;
    }

    public static String genId(Node source, Node dest) {
        if(source == null || dest == null) {
            throw new IllegalArgumentException("Invalid node!");
        }
        return source.getId() + "_" + dest.getId();
    }

    public Node getSource() {
        return source;
    }

    public Node getDest() {
        return dest;
    }

    public Integer getWeight() {
        return weight;
    }
}
