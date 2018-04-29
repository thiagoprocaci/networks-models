package com.tbp.network.structure.dtw;

import java.util.List;

public class LevenshteinDistance implements DTW {
    @Override
    public double execute(List<Integer> s, List<Integer> t) {
        org.apache.commons.text.similarity.LevenshteinDistance levenshteinDistance =  org.apache.commons.text.similarity.LevenshteinDistance.getDefaultInstance();
        return levenshteinDistance.apply(s.toString(), t.toString());

    }

}
