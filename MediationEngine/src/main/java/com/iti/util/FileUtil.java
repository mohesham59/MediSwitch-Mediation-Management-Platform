package com.iti.util;

import com.iti.fetcher.FileFetcher;
import java.io.File;

public class FileUtil {

    /**
     * "Move to processed" = delete from FTP + delete local temp copy.
     * The concept of a local processed/ folder no longer applies —
     * files live on FTP, so we just remove them after processing.
     */
    public static void moveToProcessed(File file) {
        // ✅ Delete from FTP and remove local temp file
        FileFetcher.deleteFromFtp(file);
        System.out.println("✅ Deleted from FTP + local temp: " + file.getName());
    }
}
