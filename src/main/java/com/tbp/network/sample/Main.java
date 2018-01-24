package com.tbp.network.sample;


import com.tbp.network.model.ErdosRenyi;
import org.graphstream.graph.Graph;
import org.graphstream.graph.implementations.*;

/**
 * Created by thiago on 23/01/18.
 */
public class Main {
    public static void main(String args[]) {

        ErdosRenyi erdosRenyi = new ErdosRenyi(100, 1000,1d);
        erdosRenyi.generate();
    }

}
