package com.iti.model;

import java.util.HashMap;
import java.util.Map;

public class CDRRecord {

    private Map<String, String> data;

    public CDRRecord() {
        data = new HashMap<>();
    }

    // ── Core map operations ───────────────────────────────────────────────────

    public void put(String key, String value) {
        data.put(key, value);
    }

    public String get(String key) {
        return data.get(key);
    }

    public Map<String, String> getData() {
        return data;
    }

    // ── Convenience getters (used by CSVBuilder & others) ────────────────────

    /** Returns the "source" field (MSC / PGW / SMSC / UNKNOWN). */
    public String getSource() {
        String src = data.get("source");
        return src != null ? src : "UNKNOWN";
    }

    /** Returns the "timestamp" field derived from the filename or start_time. */
    public String getTimestamp() {
        String ts = data.get("timestamp");
        return ts != null ? ts : String.valueOf(System.currentTimeMillis());
    }

    /** Returns the "record_type" field (VOICE / DATA / SMS). */
    public String getRecordType() {
        String rt = data.get("record_type");
        return rt != null ? rt : "UNKNOWN";
    }

    /** Returns the full data map as a flat key=value string (safe for CSV). */
    public String getDataAsString() {
        StringBuilder sb = new StringBuilder();
        for (Map.Entry<String, String> entry : data.entrySet()) {
            if (sb.length() > 0) sb.append("|");
            sb.append(entry.getKey()).append("=").append(entry.getValue());
        }
        return sb.toString();
    }

    @Override
    public String toString() {
        return "CDRRecord{source=" + getSource()
                + ", timestamp=" + getTimestamp()
                + ", fields=" + data.size() + "}";
    }
}