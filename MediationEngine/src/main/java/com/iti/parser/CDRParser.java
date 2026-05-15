package com.iti.parser;

import com.iti.model.CDRRecord;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;

public class CDRParser {

    public CDRRecord parse(File file) {

        CDRRecord record = new CDRRecord();

        try (BufferedReader br =
                     new BufferedReader(
                             new FileReader(file))) {

            String line;

            while ((line = br.readLine()) != null) {

                String[] parts = line.split("=", 2);

                if (parts.length == 2) {

                    record.put(
                            parts[0].trim(),
                            parts[1].trim()
                    );
                }
            }

        } catch (Exception e) {

            e.printStackTrace();
        }

        return record;
    }
}