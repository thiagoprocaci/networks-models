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
    }

}
