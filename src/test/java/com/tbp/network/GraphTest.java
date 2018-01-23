package com.tbp.network;


import org.junit.Test;

import java.util.Collection;

import static org.junit.Assert.*;

public class GraphTest {

    @Test
    public void creation() {
        Graph g = new Graph();
        assertNotNull(g.getEdges());
        assertNotNull(g.getNodes());
        assertTrue(g.getEdges().isEmpty());
        assertTrue(g.getNodes().isEmpty());
    }

    @Test
    public void addEdge() {
        Graph g = new Graph();
        g.addEdge("1", "2");
        g.addEdge("1", "2");
        g.addEdge("2", "1");
        g.addEdge("1", "4");

        assertNotNull(g.getEdges());
        assertEquals(3, g.getEdges().size());

        // edge 1_2
        assertNotNull(g.getEdges().get("1_2"));
        assertEquals("1_2", g.getEdges().get("1_2").getId());
        assertEquals(2, g.getEdges().get("1_2").getWeight().intValue());

        assertNotNull(g.getEdges().get("1_2").getSource());
        assertNotNull(g.getEdges().get("1_2").getDest());

        assertEquals("1", g.getEdges().get("1_2").getSource().getId());
        assertEquals("2", g.getEdges().get("1_2").getDest().getId());

        // edge 2_1
        assertNotNull(g.getEdges().get("2_1"));
        assertEquals("2_1", g.getEdges().get("2_1").getId());
        assertEquals(1, g.getEdges().get("2_1").getWeight().intValue());

        assertNotNull(g.getEdges().get("2_1").getSource());
        assertNotNull(g.getEdges().get("2_1").getDest());

        assertEquals("2", g.getEdges().get("2_1").getSource().getId());
        assertEquals("1", g.getEdges().get("2_1").getDest().getId());

        // edge 1_4
        assertNotNull(g.getEdges().get("1_4"));
        assertEquals("1_4", g.getEdges().get("1_4").getId());
        assertEquals(1, g.getEdges().get("1_4").getWeight().intValue());

        assertNotNull(g.getEdges().get("1_4").getSource());
        assertNotNull(g.getEdges().get("1_4").getDest());

        assertEquals("1", g.getEdges().get("1_4").getSource().getId());
        assertEquals("4", g.getEdges().get("1_4").getDest().getId());

    }

    @Test
    public void addNode() {
        Graph g = new Graph();

        g.addNode("1");
        g.addNode("2");
        g.addNode("1");
        g.addNode("3");

        assertNotNull(g.getNodes());
        assertFalse(g.getNodes().isEmpty());
        assertEquals(3, g.getNodes().size());

        Collection<Node> nodes = g.getNodes().values();
        assertNotNull(nodes);
        assertFalse(nodes.isEmpty());
        for(Node n: nodes) {
            assertTrue("1".equals(n.id) || "2".equals(n.id) || "3".equals(n.id));
        }
    }

}
