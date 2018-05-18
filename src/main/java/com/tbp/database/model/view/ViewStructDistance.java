package com.tbp.database.model.view;




import com.tbp.network.mst.support.ComparableEdge;

import java.math.BigInteger;

public interface ViewStructDistance<T> extends ComparableEdge<T> {

    Integer getDegreeNode1();

    Integer getDegreeNode2();

    BigInteger getNode1();

    BigInteger getNode2();
}
