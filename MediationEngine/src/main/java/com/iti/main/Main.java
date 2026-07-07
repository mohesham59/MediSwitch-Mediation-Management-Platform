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

    private static final int SLEEP_IDLE    = 10_000;
    private static final int SLEEP_BACKLOG =  2_000;

    // separator line printed between CDR processing blocks
    private static final String SEP =
        "─────────────────────────────────────────────────────────";

    public static void main(String[] args) {
        FileFetcher   fetcher       = new FileFetcher();
        CDRParser     parser        = new CDRParser();
        FilterService filterService = new FilterService();
        RouterService routerService = new RouterService();
        CSVBuilder    csvBuilder    = new CSVBuilder();

        System.out.println("🚀 Mediation Engine started.");

        while (true) {
            try {
                System.out.println("\nChecking for files...");
                List<File> files = fetcher.fetchFiles();

                for (File file : files) {
                    System.out.println(SEP);
                    System.out.println("📥 Processing : " + file.getName());

                    // 1. Parse
                    CDRRecord record = parser.parse(file);
                    System.out.println("📋 Fields     : " + record.getData().size());
                    System.out.println("🕐 Timestamp  : " + record.getTimestamp());

                    // 2. Filter
                    boolean allowed;
                    try {
                        allowed = filterService.isAllowed(record);
                    } catch (Exception e) {
                        System.out.println("❌ FILTER ERROR — skipping");
                        e.printStackTrace();
                        FileUtil.moveToProcessed(file);
                        continue;
                    }

                    if (!allowed) {
                        System.out.println("🚫 Filtered   : " + file.getName());
                        FileUtil.moveToProcessed(file);
                        continue;
                    }

                    // 3. Source  ← ✅ FIX: extract from filename, not path
                    String source = extractSource(file.getName());
                    System.out.println("📡 Source     : " + source);

                    // 4. Route
                    List<String> destinations;
                    try {
                        destinations = routerService.getDestinations(source);
                    } catch (Exception e) {
                        System.out.println("❌ ROUTER ERROR — skipping");
                        e.printStackTrace();
                        FileUtil.moveToProcessed(file);
                        continue;
                    }

                    System.out.println("🎯 Dests      : " + destinations);

                    if (destinations == null || destinations.isEmpty()) {
                        System.out.println("⚠️  No destinations found");
                        FileUtil.moveToProcessed(file);
                        continue;
                    }

                    // 5. Buffer
                    for (String dest : destinations) {
                        csvBuilder.addRecord(dest, record);
                    }

                    // 6. Delete from FTP
                    FileUtil.moveToProcessed(file);
                    System.out.println("✅ Done       : " + file.getName());
                }

                // 7. Flush CSV to FTP downstream
                csvBuilder.flush();

                int sleep = files.isEmpty() ? SLEEP_IDLE : SLEEP_BACKLOG;
                System.out.println(SEP);
                System.out.println("💤 Sleeping " + (sleep / 1000) + "s...\n");
                Thread.sleep(sleep);

            } catch (InterruptedException ie) {
                System.out.println("Engine interrupted — shutting down.");
                Thread.currentThread().interrupt();
                break;
            } catch (Exception e) {
                System.out.println("❌ SYSTEM ERROR");
                e.printStackTrace();
                try { Thread.sleep(5_000); } catch (InterruptedException ignored) {}
            }
        }
    }

    /**
     * ✅ FIX: extract source from the local filename which starts with node prefix.
     * Local temp filename format: msc-node_msc_cdr_20260707_203518.txt
     */
    private static String extractSource(String filename) {
        String lower = filename.toLowerCase();
        if (lower.startsWith("msc-node_"))  return "MSC";
        if (lower.startsWith("pgw-node_"))  return "PGW";
        if (lower.startsWith("smsc-node_")) return "SMSC";
        // fallback: scan for node name anywhere in filename
        if (lower.contains("msc"))  return "MSC";
        if (lower.contains("pgw"))  return "PGW";
        if (lower.contains("smsc")) return "SMSC";
        return "UNKNOWN";
    }
}
