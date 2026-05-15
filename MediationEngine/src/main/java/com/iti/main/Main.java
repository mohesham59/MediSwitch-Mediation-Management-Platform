package com.iti.main;

import com.iti.csv.CSVBuilder;
import com.iti.fetcher.FileFetcher;
import com.iti.filter.FilterService;
import com.iti.model.CDRRecord;
import com.iti.parser.CDRParser;
import com.iti.router.RouterService;
import com.iti.util.FileUtil;

import java.io.File;
import java.util.List;

public class Main {

    public static void main(String[] args) {

        FileFetcher fetcher = new FileFetcher();
        CDRParser parser = new CDRParser();
        FilterService filterService = new FilterService();
        RouterService routerService = new RouterService();
        CSVBuilder csvBuilder = new CSVBuilder();

        while (true) {

            try {

                System.out.println("\nChecking for files...");

                List<File> files = fetcher.fetchFiles();

                for (File file : files) {

                    System.out.println("Processing: " + file.getName());

                    // 1. Parse
                    CDRRecord record = parser.parse(file);
                    System.out.println("PARSED RECORD: " + record.getData());

                    // 2. Filter (FAIL FAST)
                    boolean allowed;
                    try {
                        allowed = filterService.isAllowed(record);
                    } catch (Exception e) {
                        System.out.println("❌ FILTER ERROR - skipping file: " + file.getName());
                        e.printStackTrace();
                        FileUtil.moveToProcessed(file);
                        continue;
                    }

                    System.out.println("ALLOWED: " + allowed);

                    if (!allowed) {
                        System.out.println("Filtered: " + file.getName());
                        FileUtil.moveToProcessed(file);
                        continue;
                    }

                    // 3. Extract source
                    String source = extractSource(file);

                    System.out.println("SOURCE: " + source);

                    // 4. Routing (FAIL FAST)
                    List<String> destinations;
                    try {
                        destinations = routerService.getDestinations(source);
                    } catch (Exception e) {
                        System.out.println("❌ ROUTER ERROR - skipping file: " + file.getName());
                        e.printStackTrace();
                        FileUtil.moveToProcessed(file);
                        continue;
                    }

                    System.out.println("DESTS: " + destinations);

                    if (destinations == null || destinations.isEmpty()) {
                        System.out.println("⚠️ No destinations found");
                        FileUtil.moveToProcessed(file);
                        continue;
                    }

                    // 5. Build CSV
                    for (String destination : destinations) {
                        csvBuilder.addRecord(destination, record);
                    }

                    // 6. Move file
                    FileUtil.moveToProcessed(file);
                }

                // flush output
                csvBuilder.flush();

                Thread.sleep(10000);

            } catch (Exception e) {
                System.out.println("❌ SYSTEM ERROR (main loop crashed)");
                e.printStackTrace();
            }
        }
    }

    private static String extractSource(File file) {

        String path = file.getAbsolutePath().toLowerCase();

        if (path.contains("smsc-node")) return "SMSC"; 
        if (path.contains("msc-node"))  return "MSC";
        if (path.contains("pgw-node"))  return "PGW";
        return "UNKNOWN";
        }
}