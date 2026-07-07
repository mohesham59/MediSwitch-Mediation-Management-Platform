package com.iti.csv;   
import com.iti.model.CDRRecord;

import java.io.*;
import java.net.*;
import java.nio.file.*;
import java.util.*;

public class CSVBuilder {

    private static final String FTP_HOST        = env("FTP_HOST",            "ftp-server");
    private static final int    FTP_PORT        = Integer.parseInt(env("FTP_PORT", "21"));
    private static final String FTP_USER        = env("FTP_USER",            "mediuser");
    private static final String FTP_PASS        = env("FTP_PASS",            "medipass");
    private static final String DOWNSTREAM_BASE = env("FTP_DOWNSTREAM_BASE", "/downstream");

    private final Map<String, List<CDRRecord>> buffer = new HashMap<>();

    public void addRecord(String destination, CDRRecord record) {
        buffer.computeIfAbsent(destination, k -> new ArrayList<>()).add(record);
    }

    public void flush() {
        if (buffer.isEmpty()) return;

        for (Map.Entry<String, List<CDRRecord>> entry : buffer.entrySet()) {
            String dest             = entry.getKey().toLowerCase();
            List<CDRRecord> records = entry.getValue();

            String fileName  = dest + "_cdr_" + System.currentTimeMillis() + ".csv";
            String remotePath = DOWNSTREAM_BASE + "/" + dest + "-node/cdr-files/" + fileName;

            // ── Build CSV content ─────────────────────────────────────
            StringBuilder sb = new StringBuilder();
            sb.append("timestamp,source,destination,record_type,caller_id,")
              .append("receiver_id,duration,data_usage_mb,message_length,")
              .append("external_charges,extra\n");

            for (CDRRecord record : records) {
                sb.append(esc(record.getTimestamp())).append(',')
                  .append(esc(record.getSource())).append(',')
                  .append(dest).append(',')
                  .append(esc(record.get("record_type"))).append(',')
                  .append(esc(firstNonNull(record,"caller_id","sender_id","imsi"))).append(',')
                  .append(esc(firstNonNull(record,"receiver_id","called_number",""))).append(',')
                  .append(esc(firstNonNull(record,"duration","session_duration",""))).append(',')
                  .append(esc(record.get("data_usage_mb"))).append(',')
                  .append(esc(record.get("message_length"))).append(',')
                  .append(esc(record.get("external_charges"))).append(',')
                  .append(buildExtra(record)).append('\n');
            }

            // ── Upload via raw FTP socket ─────────────────────────────
            try {
                Path tmp = Files.createTempFile("mediflow-out-", ".csv");
                Files.writeString(tmp, sb.toString());
                uploadFtp(tmp.toFile(), remotePath);
                Files.deleteIfExists(tmp);
                System.out.println("📄 Flushed " + records.size()
                        + " record(s) → FTP:" + remotePath);
            } catch (Exception e) {
                System.out.println("❌ Failed to write/upload CSV for: " + dest);
                e.printStackTrace();
            }
        }
        buffer.clear();
    }

    // ── Raw FTP upload (EPSV, no URLConnection) ──────────────────────────────

    private void uploadFtp(File localFile, String remotePath) throws IOException {
        try (Socket ctrl = new Socket()) {
            ctrl.connect(new InetSocketAddress(FTP_HOST, FTP_PORT), 10000);
            ctrl.setSoTimeout(15000);

            BufferedReader in  = new BufferedReader(
                    new InputStreamReader(ctrl.getInputStream(),  "UTF-8"));
            PrintWriter    out = new PrintWriter(
                    new OutputStreamWriter(ctrl.getOutputStream(), "UTF-8"), true);

            readReply(in);                                   // 220 welcome
            cmd(out, "USER " + FTP_USER, in);               // 331
            String login = cmd(out, "PASS " + FTP_PASS, in);// 230
            if (!login.startsWith("230"))
                throw new IOException("FTP login failed: " + login);

            cmd(out, "TYPE I", in);                          // 200 binary

            // EPSV for data connection
            int dataPort = epsv(in, out);
            if (dataPort < 0)
                throw new IOException("Could not open data channel");

            // MKD to ensure remote directory exists
            String dir = remotePath.substring(0, remotePath.lastIndexOf('/'));
            out.println("MKD " + dir);
            readReply(in); // ignore result (may already exist)

            // Open data socket BEFORE sending STOR
            try (Socket data = new Socket(FTP_HOST, dataPort)) {
                data.setSoTimeout(15000);

                out.println("STOR " + remotePath);
                String storReply = readReply(in);
                if (!storReply.startsWith("125") && !storReply.startsWith("150"))
                    throw new IOException("STOR rejected: " + storReply);

                try (InputStream fileIn   = new FileInputStream(localFile);
                     OutputStream dataOut = data.getOutputStream()) {
                    byte[] buf = new byte[8192];
                    int n;
                    while ((n = fileIn.read(buf)) != -1) dataOut.write(buf, 0, n);
                }
            }

            readReply(in); // 226 transfer complete
            out.println("QUIT");
            readReply(in);
        }
    }

    // ── EPSV ─────────────────────────────────────────────────────────────────

    private int epsv(BufferedReader in, PrintWriter out) throws IOException {
        out.println("EPSV");
        String reply = readReply(in);
        if (reply.startsWith("229")) {
            int s = reply.lastIndexOf('|');
            int e = reply.lastIndexOf('|', s - 1);
            if (s > 0 && e >= 0) {
                try { return Integer.parseInt(reply.substring(e + 1, s).trim()); }
                catch (NumberFormatException ignored) {}
            }
        }
        // fallback to PASV
        out.println("PASV");
        reply = readReply(in);
        if (!reply.startsWith("227")) return -1;
        int s = reply.indexOf('('), e = reply.indexOf(')');
        if (s < 0 || e < 0) return -1;
        String[] p = reply.substring(s + 1, e).split(",");
        return Integer.parseInt(p[4].trim()) * 256 + Integer.parseInt(p[5].trim());
    }

    private String cmd(PrintWriter out, String command, BufferedReader in) throws IOException {
        out.println(command);
        return readReply(in);
    }

    private String readReply(BufferedReader in) throws IOException {
        String line = in.readLine();
        if (line == null) return "";
        while (line.length() >= 4 && line.charAt(3) == '-') {
            line = in.readLine();
            if (line == null) break;
        }
        return line == null ? "" : line;
    }

    // ── CSV helpers ───────────────────────────────────────────────────────────

    private String esc(String v) {
        if (v == null || v.isEmpty()) return "";
        return v.contains(",") ? "\"" + v.replace("\"", "\"\"") + "\"" : v;
    }

    private String firstNonNull(CDRRecord r, String... keys) {
        for (String k : keys) {
            String v = r.get(k);
            if (v != null && !v.isEmpty()) return v;
        }
        return "";
    }

    private String buildExtra(CDRRecord r) {
        Set<String> skip = new HashSet<>(Arrays.asList(
            "timestamp","source","record_type","caller_id","sender_id","imsi",
            "receiver_id","called_number","duration","session_duration",
            "data_usage_mb","message_length","external_charges",
            "filename","file_id","rated_flag"
        ));
        StringBuilder sb = new StringBuilder();
        for (Map.Entry<String, String> e : r.getData().entrySet()) {
            if (!skip.contains(e.getKey())) {
                if (sb.length() > 0) sb.append(';');
                sb.append(e.getKey()).append('=').append(e.getValue());
            }
        }
        return sb.toString();
    }

    private static String env(String key, String def) {
        String v = System.getenv(key);
        return (v != null && !v.isBlank()) ? v : def;
    }
}
