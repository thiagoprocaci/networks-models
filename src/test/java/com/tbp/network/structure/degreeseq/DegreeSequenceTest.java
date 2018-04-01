package com.tbp.network.structure.degreeseq;


import com.tbp.network.model.BarabasiModel;
import com.tbp.network.model.NetworkModel;

import org.graphstream.graph.Graph;
import org.graphstream.graph.implementations.SingleGraph;
import org.junit.Before;
import org.junit.Test;



import java.util.List;
import java.util.Map;

import static org.junit.Assert.*;

public class DegreeSequenceTest {

    Graph g;
    DegreeSequence degreeSequence;

    @Before
    public void before() {
        g = new SingleGraph("Graph");
        g.addNode("A");
        g.addNode("B");
        g.addNode("C");
        g.addNode("U");
        g.addNode("V");
        g.addNode("D");
        g.addNode("E");
        g.addNode("F");
        g.addNode("G");
        g.addEdge("A_B", "A", "B");
        g.addEdge("A_C", "A", "C");
        g.addEdge("C_B", "C", "B");
        g.addEdge("B_V", "B", "V");
        g.addEdge("B_U", "B", "U");
        g.addEdge("U_V", "U", "V");
        g.addEdge("U_E", "U", "E");
        g.addEdge("U_D", "U", "D");
        g.addEdge("V_D", "V", "D");
        g.addEdge("D_F", "D", "F");
        g.addEdge("D_G", "D", "G");
        g.addEdge("F_G", "F", "G");

        degreeSequence = new DegreeSequence();
    }

    @Test
    public void executeStartNodeA() {
        Map<Integer, List<Integer>> degreeSeq = degreeSequence.execute("A", g);
        assertEquals(5, degreeSeq.size());

        assertEquals(new Object[]{2}, degreeSeq.get(0).toArray()); // degree of A
        assertEquals(new Object[]{2, 4}, degreeSeq.get(1).toArray()); // degree of C, B
        assertEquals(new Object[]{3, 4}, degreeSeq.get(2).toArray()); // degree of V, U
        assertEquals(new Object[]{1, 4}, degreeSeq.get(3).toArray()); // degree of E, D
        assertEquals(new Object[]{2, 2}, degreeSeq.get(4).toArray()); // // degree of F, G

    }

    @Test
    public void executeStartNodeAWithMaxLevel2() {
        Map<Integer, List<Integer>> degreeSeq2 = degreeSequence.execute("A", g, 2);
        assertEquals(3, degreeSeq2.size());

        assertEquals(new Object[]{2}, degreeSeq2.get(0).toArray()); // degree of A
        assertEquals(new Object[]{2, 4}, degreeSeq2.get(1).toArray()); // degree of C, B
        assertEquals(new Object[]{3, 4}, degreeSeq2.get(2).toArray()); // degree of V, U
    }


    @Test
    public void executeStartNodeV() {
        Map<Integer, List<Integer>> degreeSeq = degreeSequence.execute("V", g);
        assertEquals(3, degreeSeq.size());
        assertEquals(new Object[]{3}, degreeSeq.get(0).toArray()); // degree of V
        assertEquals(new Object[]{4, 4, 4}, degreeSeq.get(1).toArray()); // degree of B, U, D
        assertEquals(new Object[]{1, 2, 2, 2, 2}, degreeSeq.get(2).toArray()); // degree of E, A, C, F, G
    }

    @Test
    public void executeStartNodeU() {
        Map<Integer, List<Integer>> degreeSeq = degreeSequence.execute("U", g);
        assertEquals(3, degreeSeq.size());
        assertEquals(new Object[]{4}, degreeSeq.get(0).toArray()); // degree of U
        assertEquals(new Object[]{1, 3, 4, 4}, degreeSeq.get(1).toArray()); // degree of E, V, D, B
        assertEquals(new Object[]{2,2,2,2}, degreeSeq.get(2).toArray()); // degree of A, C, F, G
    }

    @Test
    public void noException() {
        NetworkModel m = new BarabasiModel(1000);
        Map<Integer, List<Integer>> degreeSeq = degreeSequence.execute("0", m.getGraph());
        assertTrue(!degreeSeq.isEmpty());
    }

    @Test
    public void noExceptionWithMaxLevel() {
        NetworkModel m = new BarabasiModel(1000);
        Map<Integer, List<Integer>> degreeSeq = degreeSequence.execute("0", m.getGraph(), 4);
        assertTrue(!degreeSeq.isEmpty());
        assertEquals(5, degreeSeq.size());

        Map<Integer, List<Integer>> degreeSeq2 = degreeSequence.execute("0", m.getGraph());
        assertTrue(!degreeSeq2.isEmpty());
        assertEquals(degreeSeq.get(0), degreeSeq2.get(0));
        assertEquals(degreeSeq.get(1), degreeSeq2.get(1));
        assertEquals(degreeSeq.get(2), degreeSeq2.get(2));
        assertEquals(degreeSeq.get(3), degreeSeq2.get(3));
        assertEquals(degreeSeq.get(4), degreeSeq2.get(4));
    }

    @Test
    public void perfomanceTest() {
        NetworkModel m = new BarabasiModel(1000);
        long startTime = System.currentTimeMillis();
        degreeSequence.execute("0", m.getGraph());
        long totalTime1 = System.currentTimeMillis() - startTime;
        startTime = System.currentTimeMillis();
        degreeSequence.execute("0", m.getGraph(), 2);
        long totalTime2 = System.currentTimeMillis() - startTime;
        assertTrue(totalTime2 < totalTime1);
    }
}
