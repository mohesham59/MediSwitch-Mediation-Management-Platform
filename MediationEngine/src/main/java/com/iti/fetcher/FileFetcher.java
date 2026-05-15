package com.iti.fetcher;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

public class FileFetcher {

    /**
     * Priority:
     *  1. Environment variable  UPSTREAM_BASE_PATH   (set by Docker or shell)
     *  2. Java system property  upstream.base.path   (set via -D flag)
     *  3. Hard-coded fallback   (your local dev path)
     */
    private static final String BASE_PATH = resolveBasePath();

    private static String resolveBasePath() {
        // 1. Docker / shell env variable
        String env = System.getenv("UPSTREAM_BASE_PATH");
        if (env != null && !env.isBlank()) {
            System.out.println("[FileFetcher] Using UPSTREAM_BASE_PATH env: " + env);
            return env;
        }
        // 2. JVM system property  (-Dupstream.base.path=...)
        String prop = System.getProperty("upstream.base.path");
        if (prop != null && !prop.isBlank()) {
            System.out.println("[FileFetcher] Using system property upstream.base.path: " + prop);
            return prop;
        }
        // 3. Fallback – local dev absolute path (change to yours if needed)
        String fallback = "/home/omar/med_project/MediSwitch-Mediation-Management-Platform"
                        + "/mediation-docker/Up-Stream-Nodes";
        System.out.println("[FileFetcher] Using fallback path: " + fallback);
        return fallback;
    }

    public List<File> fetchFiles() {
        List<File> files = new ArrayList<>();

        File root = new File(BASE_PATH);
        System.out.println("ROOT EXISTS : " + root.exists());
        System.out.println("ROOT PATH   : " + root.getAbsolutePath());

        File[] nodes = root.listFiles(File::isDirectory);
        if (nodes == null) {
            System.out.println("NO NODES FOUND under: " + BASE_PATH);
            return files;
        }

        for (File node : nodes) {
            System.out.println("NODE: " + node.getName());

            File cdrFolder = new File(node, "cdr-files");
            System.out.println("CDR PATH: " + cdrFolder.getAbsolutePath());

            File[] txtFiles = cdrFolder.listFiles(
                    (dir, name) -> name.endsWith(".txt")
            );

            if (txtFiles != null) {
                for (File file : txtFiles) {
                    System.out.println("FOUND FILE: " + file.getName());
                    files.add(file);
                }
            }
        }
        return files;
    }
}