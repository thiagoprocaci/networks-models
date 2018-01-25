package com.tbp.network.sample;

import com.tbp.network.model.BarabasiModel;
import com.tbp.network.model.ErdosRenyi;


public class Main {
    public static void main(String args[]) {

    //    ErdosRenyi erdosRenyi = new ErdosRenyi(100, 1000,1d);
      //  erdosRenyi.generate();

        BarabasiModel barabasiModel = new BarabasiModel(1000);
        barabasiModel.generate();
    }

}
