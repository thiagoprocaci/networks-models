package com.tbp.network.structure.dtw;


import com.tbp.network.structure.degreeseq.DegreeSequence;
import com.tbp.network.structure.dtw.distance.EuclideanDistance;
import com.tbp.network.structure.dtw.distance.OtherDistance;
import org.graphstream.graph.Graph;
import org.graphstream.graph.implementations.SingleGraph;
import org.junit.Before;
import org.junit.Test;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import static org.junit.Assert.*;

public class TraditionalDTWTest {

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
    public void execute() {
        Map<Integer, List<Integer>> s = degreeSequence.execute("U", g);
        Map<Integer, List<Integer>> t = degreeSequence.execute("V", g);

        TraditionalDTW dtw = new TraditionalDTW(new OtherDistance());

        double val = dtw.execute(s.get(0), t.get(0));
        assertEquals(0.33, Math.floor(val * 100) / 100, 0.001);

        val = dtw.execute(s.get(1), t.get(1));
        assertEquals(3.33, Math.floor(val * 100) / 100, 0.001);

        val = dtw.execute(s.get(2), t.get(2));
        assertEquals(1.0, Math.floor(val * 100) / 100, 0.001);
    }

    @Test
    public void execute2() {
        int[] s = {1,3,4,9,8,2,1,5,7,3};
        int[] t = {1,6,2,3,0,9,4,3,6,3};

        List<Integer> s1 = new ArrayList<Integer>();
        List<Integer> t1 = new ArrayList<Integer>();

        for(int i = 0; i < s.length; i++) {
            s1.add(s[i]);
        }
        for(int i = 0; i < t.length; i++) {
            t1.add(t[i]);
        }

        TraditionalDTW dtw = new TraditionalDTW(new EuclideanDistance());
        double val = dtw.execute(s1, t1);


        assertEquals(15, Math.floor(val * 100) / 100, 0.001);

    }

}
