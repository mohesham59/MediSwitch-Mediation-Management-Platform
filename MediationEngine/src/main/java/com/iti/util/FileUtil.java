package com.iti.util;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;

public class FileUtil {

    /**
     * Moves a processed CDR file into the  processed/  sub-folder
     * that sits next to the file's own cdr-files directory.
     *
     * Works for any absolute path — no path constants needed here.
     */
    public static void moveToProcessed(File file) {
        // The processed/ folder lives inside the same cdr-files/ directory
        File processedDir = new File(file.getParent(), "processed");

        if (!processedDir.exists()) {
            boolean created = processedDir.mkdirs();
            if (!created) {
                System.out.println("⚠️  Could not create processed dir: "
                        + processedDir.getAbsolutePath());
                return;
            }
        }

        File destination = new File(processedDir, file.getName());
        try {
            Files.move(file.toPath(), destination.toPath(),
                    StandardCopyOption.REPLACE_EXISTING);
            System.out.println("✅ Moved to processed: " + file.getName());
        } catch (IOException e) {
            System.out.println("❌ Failed to move file: " + file.getName());
            e.printStackTrace();
        }
    }
}