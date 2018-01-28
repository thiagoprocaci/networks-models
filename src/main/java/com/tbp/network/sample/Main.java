package com.tbp.network.sample;


import com.tbp.network.gui.GuiBuilder;
import com.tbp.network.model.BarabasiModel;
import com.tbp.network.model.ErdosRenyi;
import com.tbp.network.model.NetworkModel;
import org.graphstream.ui.view.View;
import org.graphstream.ui.view.Viewer;

import javax.swing.*;


public class Main {
    public static void main(String args[]) {

        
        //          new ErdosRenyi(1000);
        
        //System.setProperty("org.graphstream.ui.renderer", "org.graphstream.ui.j2dviewer.J2DGraphRenderer");
        // new ErdosRenyi(10000);//
        NetworkModel model =  new BarabasiModel(10000);

        model.getGraph().display();

    }

}
