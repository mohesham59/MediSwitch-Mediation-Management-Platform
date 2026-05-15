package com.iti.csv;

import com.iti.model.CDRRecord;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class CSVBuilder {

    /**
     * Priority:
     *  1. Environment variable  DOWNSTREAM_BASE_PATH
     *  2. Java system property  downstream.base.path
     *  3. Hard-coded fallback
     */
    private static final String DOWNSTREAM_BASE = resolveDownstreamPath();

    private static String resolveDownstreamPath() {
        String env = System.getenv("DOWNSTREAM_BASE_PATH");
        if (env != null && !env.isBlank()) {
            System.out.println("[CSVBuilder] Using DOWNSTREAM_BASE_PATH env: " + env);
            return env;
        }
        String prop = System.getProperty("downstream.base.path");
        if (prop != null && !prop.isBlank()) {
            System.out.println("[CSVBuilder] Using system property downstream.base.path: " + prop);
            return prop;
        }
        return null;
    }

    // destination name  →  list of records to write
    private final Map<String, List<CDRRecord>> buffer = new HashMap<>();

    public void addRecord(String destination, CDRRecord record) {
        buffer.computeIfAbsent(destination, k -> new ArrayList<>()).add(record);
    }

    /**
     * Writes all buffered records to  <downstream-base>/<dest>-node/cdr-files/<dest>_cdr_<ts>.csv
     * then clears the buffer.
     */
    public void flush() {
        if (buffer.isEmpty()) return;

        for (Map.Entry<String, List<CDRRecord>> entry : buffer.entrySet()) {
            String dest    = entry.getKey();          // e.g. "billing"
            List<CDRRecord> records = entry.getValue();

            // Build output folder:  <DOWNSTREAM_BASE>/<dest>-node/cdr-files/
            File outDir = new File(DOWNSTREAM_BASE,
                    dest.toLowerCase() + "-node/cdr-files");

            if (!outDir.exists()) {
                boolean created = outDir.mkdirs();
                if (!created) {
                    System.out.println("⚠️  Cannot create output dir: "
                            + outDir.getAbsolutePath());
                    continue;
                }
            }

            String timestamp = String.valueOf(System.currentTimeMillis());
            File outFile = new File(outDir,
                    dest.toLowerCase() + "_cdr_" + timestamp + ".csv");

            try (PrintWriter pw = new PrintWriter(new FileWriter(outFile, true))) {
                // header only when file is new / empty
                if (outFile.length() == 0) {
                    pw.println("timestamp,source,destination,data");
                }
                for (CDRRecord record : records) {
                    pw.printf("%s,%s,%s,%s%n",
                            record.getTimestamp(),
                            record.getSource(),
                            dest,
                            record.getData().replace(",", ";")   // escape commas
                    );
                }
                System.out.println("📄 Flushed " + records.size()
                        + " record(s) → " + outFile.getName());
            } catch (IOException e) {
                System.out.println("❌ Failed to write CSV for: " + dest);
                e.printStackTrace();
            }
        }
        buffer.clear();
    }
}