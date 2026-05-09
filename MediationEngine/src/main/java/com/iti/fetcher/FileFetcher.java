package com.iti.fetcher;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

public class FileFetcher {

    private static final String BASE_PATH
            = "/home/omar/med_project/MediSwitch-Mediation-Management-Platform/mediation-docker/Up-Stream-Nodes";

    public List<File> fetchFiles() {

        List<File> files = new ArrayList<>();

        File root = new File(BASE_PATH);

        System.out.println("ROOT EXISTS: " + root.exists());
        System.out.println("ROOT PATH: " + root.getAbsolutePath());

        File[] nodes = root.listFiles(File::isDirectory);

        if (nodes == null) {

            System.out.println("NO NODES FOUND");

            return files;
        }

        for (File node : nodes) {

            System.out.println("NODE: " + node.getName());

            File cdrFolder
                    = new File(node, "cdr-files");

            System.out.println("CDR PATH: "
                    + cdrFolder.getAbsolutePath());

            File[] txtFiles
                    = cdrFolder.listFiles((dir, name)
                            -> name.endsWith(".txt"));

            if (txtFiles != null) {

                for (File file : txtFiles) {

                    System.out.println("FOUND FILE: "
                            + file.getName());

                    files.add(file);
                }
            }
        }

        return files;
    }
}
