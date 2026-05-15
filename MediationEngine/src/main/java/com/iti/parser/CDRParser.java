package com.iti.parser;

import com.iti.model.CDRRecord;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;

public class CDRParser {

    /**
     * Parses a CDR text file into a CDRRecord.
     *
     * Expected file format (key=value per line):
     *   record_type=VOICE
     *   calling_number=01012345678
     *   called_number=01098765432
     *   start_time=2026-05-08T14:30:00
     *   duration=120
     *   bytes_sent=0
     *   bytes_received=0
     *   status=SUCCESS
     */
    public CDRRecord parse(File file) {
        CDRRecord record = new CDRRecord();

        // ── 1. Extract source & timestamp from filename ──────────────────
        //    e.g.  msc_cdr_20260508_143016.txt  →  source=MSC, timestamp=20260508_143016
        String filename = file.getName();
        String source    = extractSourceFromFilename(filename);
        String timestamp = extractTimestampFromFilename(filename);

        record.put("source",    source);
        record.put("timestamp", timestamp);
        record.put("filename",  filename);

        // ── 2. Read key=value lines from the file ────────────────────────
        try (BufferedReader br = new BufferedReader(new FileReader(file))) {
            String line;
            int lineNumber = 0;

            while ((line = br.readLine()) != null) {
                lineNumber++;
                line = line.trim();

                // skip blank lines and comment lines
                if (line.isEmpty() || line.startsWith("#")) continue;

                String[] parts = line.split("=", 2);
                if (parts.length == 2) {
                    String key   = parts[0].trim();
                    String value = parts[1].trim();

                    if (!key.isEmpty()) {
                        record.put(key, value);
                    } else {
                        System.out.println("⚠️  Empty key at line "
                                + lineNumber + " in " + filename);
                    }
                } else {
                    System.out.println("⚠️  Skipping malformed line "
                            + lineNumber + ": [" + line + "] in " + filename);
                }
            }

        } catch (Exception e) {
            System.out.println("❌ Failed to parse file: " + filename);
            e.printStackTrace();
        }

        // ── 3. If file contained its own timestamp field, prefer it ──────
        //    (overrides the filename-derived one only if present)
        if (record.get("start_time") != null && !record.get("start_time").isEmpty()) {
            record.put("timestamp", record.get("start_time"));
        }

        // ── 4. Basic validation ──────────────────────────────────────────
        validateRecord(record, filename);

        System.out.println("✅ Parsed [" + source + "] " + filename
                + " → " + record.getData().size() + " fields");
        return record;
    }

    // ── Helpers ──────────────────────────────────────────────────────────────

    /**
     * Derives the node source from the filename prefix.
     *   msc_cdr_*   → MSC
     *   pgw_cdr_*   → PGW
     *   smsc_cdr_*  → SMSC
     */
    private String extractSourceFromFilename(String filename) {
        String lower = filename.toLowerCase();
        if (lower.startsWith("msc_"))  return "MSC";
        if (lower.startsWith("pgw_"))  return "PGW";
        if (lower.startsWith("smsc_")) return "SMSC";
        return "UNKNOWN";
    }

    /**
     * Extracts the timestamp portion from filenames like:
     *   msc_cdr_20260508_143016.txt  →  20260508_143016
     * Falls back to the current epoch string if the pattern doesn't match.
     */
    private String extractTimestampFromFilename(String filename) {
        // Pattern: <prefix>_cdr_<YYYYMMDD>_<HHmmss>.txt
        try {
            String withoutExt = filename.replace(".txt", "");
            String[] parts    = withoutExt.split("_");
            // parts: [msc, cdr, 20260508, 143016]
            if (parts.length >= 4) {
                return parts[2] + "_" + parts[3];   // 20260508_143016
            }
        } catch (Exception ignored) { }

        return String.valueOf(System.currentTimeMillis());
    }

    /**
     * Warns about missing expected fields based on the source type.
     * Does NOT throw — validation is advisory only; caller decides what to do.
     */
    private void validateRecord(CDRRecord record, String filename) {
        String source = record.get("source");
        if (source == null) return;

        String[] voiceFields = {"calling_number", "called_number", "duration", "status"};
        String[] dataFields  = {"calling_number", "bytes_sent", "bytes_received", "status"};
        String[] smsFields   = {"calling_number", "called_number", "status"};

        String[] required;
        switch (source) {
            case "MSC":  required = voiceFields; break;
            case "PGW":  required = dataFields;  break;
            case "SMSC": required = smsFields;   break;
            default:     return;
        }

        for (String field : required) {
            if (record.get(field) == null || record.get(field).isEmpty()) {
                System.out.println("⚠️  Missing field [" + field + "] in " + filename);
            }
        }
    }
}