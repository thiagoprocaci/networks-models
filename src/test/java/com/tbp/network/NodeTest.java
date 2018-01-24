package com.tbp.network;


import org.junit.Test;

import static org.junit.Assert.*;

public class NodeTest {


    @Test(expected = IllegalArgumentException.class)
    public void creationNullId() {
        new Node(null);
    }

    @Test(expected = IllegalArgumentException.class)
    public void creationEmptyId() {
        new Node(" ");
    }

    @Test
    public void creationValidId() {
        Node n = new Node("1");
        assertEquals("1", n.getId());
        assertEquals(0, n.getIndegree().intValue());
        assertEquals(0, n.getOutdegree().intValue());
    }

    @Test
    public void increaseDegree() {
        Node n = new Node("1");
        assertEquals("1", n.getId());
        assertEquals(0, n.getIndegree().intValue());
        assertEquals(0, n.getOutdegree().intValue());

        n.increaseIndegree();
        n.increaseOutdegree();
        n.increaseOutdegree();

        assertEquals(1, n.getIndegree().intValue());
        assertEquals(2, n.getOutdegree().intValue());
    }

}
