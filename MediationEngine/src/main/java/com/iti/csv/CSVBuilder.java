package com.iti.csv;

import com.iti.model.CDRRecord;
import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVPrinter;

import java.io.FileWriter;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

public class CSVBuilder {

    private final Map<String, List<CDRRecord>> routedRecords
            = new HashMap<>();

    public void addRecord(
            String destination,
            CDRRecord record
    ) {

        routedRecords
                .computeIfAbsent(
                        destination,
                        k -> new ArrayList<>())
                .add(record);
    }

    public void flush() {
        

        for (String destination
                : routedRecords.keySet()) {

            List<CDRRecord> records
                    = routedRecords.get(destination);
            System.out.println("FLUSHING DEST: " + destination);
System.out.println("RECORDS: " + records.size());

            if (records.isEmpty()) {
                continue;
            }

            try {

                String timestamp
                        = LocalDateTime.now()
                                .format(
                                        DateTimeFormatter
                                                .ofPattern(
                                                        "yyyyMMdd_HHmmss"
                                                )
                                );

                String fileName
                        = destination + "_"
                        + timestamp + ".csv";
                String path
                        = "/home/omar/med_project/MediSwitch-Mediation-Management-Platform/mediation-docker/Down-Stream-Nodes/"
                        + destination.toLowerCase()
                        + "-node/cdr-files/"
                        + fileName;

                FileWriter out
                        = new FileWriter(path);

                Set<String> headers
                        = records.get(0)
                                .getData()
                                .keySet();

                CSVPrinter printer
                        = new CSVPrinter(
                                out,
                                CSVFormat.DEFAULT
                                        .withHeader(
                                                headers.toArray(
                                                        new String[0]
                                                )
                                        )
                        );

                for (CDRRecord record
                        : records) {

                    List<String> values
                            = new ArrayList<>();

                    for (String h : headers) {
                        values.add(record.get(h));
                    }

                    printer.printRecord(values);
                }

                printer.flush();
                printer.close();

                System.out.println(
                        "[CSV] Created: "
                        + fileName
                );

            } catch (Exception e) {

                e.printStackTrace();
            }
        }
        

        routedRecords.clear();
    }
}
