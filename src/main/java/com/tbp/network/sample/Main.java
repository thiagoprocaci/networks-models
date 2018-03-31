package com.tbp.network.sample;


import com.tbp.network.structure.degreeseq.DegreeSequence;
import org.graphstream.graph.Graph;
import org.graphstream.graph.implementations.SingleGraph;

import java.util.List;
import java.util.Map;


public class Main {
    public static void main(String args[]) {
        
        //System.setProperty("org.graphstream.ui.renderer", "org.graphstream.ui.j2dviewer.J2DGraphRenderer");
        // new ErdosRenyi(10000);//
        //NetworkModel model =  new BarabasiModel(10000);

        //model.getGraph().display();

        Graph g = new SingleGraph("Graph");


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

        DegreeSequence degreeSequence = new DegreeSequence();

        Map<Integer, List<Integer>> u = degreeSequence.execute("U", g);
        System.out.println(u);
        u = degreeSequence.execute("V", g);
        System.out.println(u);

    }

}
