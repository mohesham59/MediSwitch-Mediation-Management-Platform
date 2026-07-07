package com.iti.fetcher;

import java.io.*;
import java.net.*;
import java.nio.file.*;
import java.util.*;

/**
 * Fetches CDR files from FTP using raw RFC 959 + EPSV (RFC 2428).
 * EPSV avoids the PASV IP-address issues in Docker networks.
 */
public class FileFetcher {

    private static final String FTP_HOST      = env("FTP_HOST",          "ftp-server");
    private static final int    FTP_PORT      = Integer.parseInt(env("FTP_PORT", "21"));
    private static final String FTP_USER      = env("FTP_USER",          "mediuser");
    private static final String FTP_PASS      = env("FTP_PASS",          "medipass");
    private static final String UPSTREAM_BASE = env("FTP_UPSTREAM_BASE", "/upstream");
    private static final int    BATCH_SIZE    = Integer.parseInt(env("MAX_FILES_PER_BATCH", "5"));

    private static final String[] NODES = {"msc-node", "pgw-node", "smsc-node"};

    private static final Path TEMP_DIR;
    static {
        try {
            TEMP_DIR = Files.createTempDirectory("mediflow-cdr-");
            System.out.println("[FileFetcher] Temp dir : " + TEMP_DIR);
            System.out.println("[FileFetcher] FTP host : " + FTP_HOST + ":" + FTP_PORT);
            System.out.println("[FileFetcher] FTP user : " + FTP_USER);
        } catch (IOException e) {
            throw new RuntimeException("Cannot create temp dir", e);
        }
    }

    // ── Public API ───────────────────────────────────────────────────────────

    public List<File> fetchFiles() {
        List<File> result = new ArrayList<>();
        for (String node : NODES) {
            String remoteDir = UPSTREAM_BASE + "/" + node + "/cdr-files";
            List<String> names = listDir(remoteDir);
            Collections.sort(names);

            int take    = Math.min(names.size(), BATCH_SIZE);
            int pending = names.size() - take;

            for (int i = 0; i < take; i++) {
                String name  = names.get(i);
                Path   local = TEMP_DIR.resolve(node + "_" + name);
                if (downloadFile(remoteDir + "/" + name, local)) {
                    result.add(local.toFile());
                    System.out.println("QUEUED: " + name);
                }
            }
            if (pending > 0)
                System.out.println("⏳ " + pending + " more pending in " + node);
        }
        return result;
    }

    public static void deleteFromFtp(File localFile) {
        String localName = localFile.getName();
        for (String node : NODES) {
            String prefix = node + "_";
            if (localName.startsWith(prefix)) {
                String remoteName = localName.substring(prefix.length());
                deleteFile(UPSTREAM_BASE + "/" + node + "/cdr-files/" + remoteName);
                break;
            }
        }
        localFile.delete();
    }

    // ── FTP session ──────────────────────────────────────────────────────────

    @FunctionalInterface
    interface FtpTask<T> {
        T run(Socket ctrl, BufferedReader in, PrintWriter out) throws Exception;
    }

    private static <T> T withFtp(FtpTask<T> task) {
        try (Socket ctrl = new Socket()) {
            ctrl.connect(new InetSocketAddress(FTP_HOST, FTP_PORT), 10000);
            ctrl.setSoTimeout(15000);

            BufferedReader in  = new BufferedReader(
                    new InputStreamReader(ctrl.getInputStream(),  "UTF-8"));
            PrintWriter    out = new PrintWriter(
                    new OutputStreamWriter(ctrl.getOutputStream(), "UTF-8"), true);

            readReply(in);                              // 220 welcome

            send(out, "USER " + FTP_USER, in, "331");
            String loginReply = send(out, "PASS " + FTP_PASS, in, null);
            if (loginReply == null || !loginReply.startsWith("230")) {
                System.out.println("❌ FTP login failed: " + loginReply);
                return null;
            }

            send(out, "TYPE I", in, "200");             // binary

            T result = task.run(ctrl, in, out);

            out.println("QUIT");
            readReply(in);
            return result;

        } catch (Exception e) {
            System.out.println("⚠️  FTP error: " + e.getMessage());
            return null;
        }
    }

    // ── List directory ────────────────────────────────────────────────────────

    private List<String> listDir(String remoteDir) {
        List<String> files = new ArrayList<>();
        List<String> raw = withFtp((ctrl, in, out) -> {
            // ✅ Use EPSV — works in Docker without IP config
            int dataPort = epsv(in, out);
            if (dataPort < 0) return Collections.emptyList();

            try (Socket data = new Socket(FTP_HOST, dataPort)) {
                data.setSoTimeout(10000);
                out.println("NLST " + remoteDir);
                String reply = readReply(in);
                if (!reply.startsWith("125") && !reply.startsWith("150"))
                    return Collections.emptyList();

                List<String> names = new ArrayList<>();
                BufferedReader dataIn = new BufferedReader(
                        new InputStreamReader(data.getInputStream(), "UTF-8"));
                String line;
                while ((line = dataIn.readLine()) != null) {
                    line = line.trim();
                    String name = line.contains("/")
                            ? line.substring(line.lastIndexOf('/') + 1) : line;
                    if (name.endsWith(".txt")) names.add(name);
                }
                readReply(in); // 226
                return names;
            }
        });
        if (raw != null) files.addAll(raw);
        return files;
    }

    // ── Download file ─────────────────────────────────────────────────────────

    private boolean downloadFile(String remotePath, Path localPath) {
        Boolean ok = withFtp((ctrl, in, out) -> {
            int dataPort = epsv(in, out);
            if (dataPort < 0) return false;

            try (Socket data = new Socket(FTP_HOST, dataPort)) {
                data.setSoTimeout(15000);
                out.println("RETR " + remotePath);
                String reply = readReply(in);
                if (!reply.startsWith("125") && !reply.startsWith("150")) {
                    System.out.println("⚠️  RETR failed: " + reply);
                    return false;
                }
                try (InputStream dataIn = data.getInputStream()) {
                    Files.copy(dataIn, localPath, StandardCopyOption.REPLACE_EXISTING);
                }
                readReply(in); // 226
                return true;
            }
        });
        return Boolean.TRUE.equals(ok);
    }

    // ── Delete file ───────────────────────────────────────────────────────────

    private static void deleteFile(String remotePath) {
        withFtp((ctrl, in, out) -> {
            out.println("DELE " + remotePath);
            String reply = readReply(in);
            if (reply.startsWith("250"))
                System.out.println("🗑️  Deleted: " + remotePath);
            else
                System.out.println("⚠️  DELE: " + reply);
            return null;
        });
    }

    // ── EPSV — Extended Passive Mode (Docker-friendly) ────────────────────────

    /**
     * Sends EPSV and returns the data port number.
     * EPSV reply format: 229 Entering Extended Passive Mode (|||PORT|)
     * No IP address involved — always connects back to FTP_HOST.
     */
    private static int epsv(BufferedReader in, PrintWriter out) throws IOException {
        out.println("EPSV");
        String reply = readReply(in);
        if (!reply.startsWith("229")) {
            System.out.println("⚠️  EPSV failed: " + reply + " — trying PASV");
            return pasvFallback(in, out);
        }
        // parse (|||port|)
        int s = reply.lastIndexOf('|');
        int e = reply.lastIndexOf('|', s - 1);
        if (s < 0 || e < 0) return -1;
        try {
            return Integer.parseInt(reply.substring(e + 1, s).trim());
        } catch (NumberFormatException ex) {
            return -1;
        }
    }

    /** PASV fallback: uses the FTP_HOST for the data connection (ignores server IP). */
    private static int pasvFallback(BufferedReader in, PrintWriter out) throws IOException {
        out.println("PASV");
        String reply = readReply(in);
        if (!reply.startsWith("227")) {
            System.out.println("⚠️  PASV also failed: " + reply);
            return -1;
        }
        int s = reply.indexOf('('), e = reply.indexOf(')');
        if (s < 0 || e < 0) return -1;
        String[] p = reply.substring(s + 1, e).split(",");
        // ignore p[0..3] (server IP) — connect to FTP_HOST instead
        int port = Integer.parseInt(p[4].trim()) * 256 + Integer.parseInt(p[5].trim());
        System.out.println("[FileFetcher] PASV fallback port: " + port);
        return port;
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private static String readReply(BufferedReader in) throws IOException {
        String line = in.readLine();
        if (line == null) return "";
        while (line.length() >= 4 && line.charAt(3) == '-') {
            line = in.readLine();
            if (line == null) break;
        }
        return line == null ? "" : line;
    }

    private static String send(PrintWriter out, String cmd,
                               BufferedReader in, String expectCode) throws IOException {
        out.println(cmd);
        String reply = readReply(in);
        if (expectCode != null && !reply.startsWith(expectCode))
            System.out.println("⚠️  Expected " + expectCode + " got: " + reply);
        return reply;
    }

    private static String env(String key, String def) {
        String v = System.getenv(key);
        return (v != null && !v.isBlank()) ? v : def;
    }
}
