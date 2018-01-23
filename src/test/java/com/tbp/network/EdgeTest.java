package com.tbp.network;


import org.junit.Before;
import org.junit.Test;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;

public class EdgeTest {

    Node source;
    Node dest;

    @Before
    public void before() {
        source = new Node("1");
        dest = new Node("2");
    }

    @Test(expected = IllegalArgumentException.class)
    public void genIdNullSource() {
        Edge.genId(null, dest);
    }

    @Test(expected = IllegalArgumentException.class)
    public void genIdNullDest() {
        Edge.genId(source, null);
    }

    @Test
    public void genIdSuccess() {
        String id = Edge.genId(source, dest);
        assertEquals(source.id + "_" + dest.id, id);
    }

    @Test(expected = IllegalArgumentException.class)
    public void creationNullSource() {
        new Edge(null, dest);
    }

    @Test(expected = IllegalArgumentException.class)
    public void creationNullDest() {
        new Edge(source, null);
    }

    @Test(expected = IllegalArgumentException.class)
    public void creationNullSourceAndNullDest() {
        new Edge(null, null);
    }

    @Test
    public void creationSuccess() {
        Edge edge = new Edge(source, dest);
        assertNotNull(edge.getWeight());
        assertEquals(1, edge.getWeight().intValue());
        assertEquals(source, edge.getSource());
        assertEquals(dest, edge.getDest());
        assertEquals(source.id + "_" + dest.id, edge.getId());
    }

    @Test
    public void increaseWeight() {
        Edge edge = new Edge(source, dest);
        assertNotNull(edge.getWeight());
        assertEquals(1, edge.getWeight().intValue());

        edge.increaseWeight();
        assertEquals(2, edge.getWeight().intValue());

        edge.increaseWeight();
        assertEquals(3, edge.getWeight().intValue());

    }
}
