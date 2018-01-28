package com.tbp.network.gui;


import javax.swing.*;

public class GuiBuilder {

    public JFrame createFrame() {
        JFrame window = new JFrame("Visual Network");
        window.setSize(500,500);
        window.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        window.setVisible(true);
        return window;
    }


}
