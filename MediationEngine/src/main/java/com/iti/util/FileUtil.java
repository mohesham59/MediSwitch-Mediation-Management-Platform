package com.iti.util;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;

public class FileUtil {

    public static void moveToProcessed(
            File file
    ) {

        try {

            File processedDir =
                    new File(
                            file.getParent()
                                    + "/processed"
                    );

            if (!processedDir.exists()) {
                processedDir.mkdirs();
            }

            File target =
                    new File(
                            processedDir,
                            file.getName()
                    );

            Files.move(
                    file.toPath(),
                    target.toPath(),
                    StandardCopyOption.REPLACE_EXISTING
            );

        } catch (Exception e) {

            e.printStackTrace();
        }
    }
}