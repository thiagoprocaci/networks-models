package com.tbp.execution.support;

import org.graphstream.graph.Graph;
import org.graphstream.stream.file.FileSinkImages;
import org.springframework.stereotype.Component;

import java.io.File;
import java.io.IOException;

@Component
public class GraphIO {

    public void saveModel(Graph graph) {
        FileSinkImages pic = new FileSinkImages(FileSinkImages.OutputType.PNG, FileSinkImages.Resolutions.VGA);
        String fileName = graph.getId() + ".png";
        File file = new File(fileName);
        if(file.exists()) {
            file.delete();
        }
        pic.setLayoutPolicy(FileSinkImages.LayoutPolicy.COMPUTED_FULLY_AT_NEW_IMAGE);
        try {
            pic.writeAll(graph, fileName);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

}
