package com.iti.database;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBConnection {

    private static final String URL
            = "jdbc:postgresql://ep-icy-tooth-ald4vfsg.c-3.eu-central-1.aws.neon.tech/neondb?sslmode=require";

    private static final String USER = "neondb_owner";

    private static final String PASSWORD = "npg_3yuY1vkJlrVm";

    public static Connection getConnection() {

        try {

            Class.forName("org.postgresql.Driver");

            Connection con
                    = DriverManager.getConnection(
                            URL,
                            USER,
                            PASSWORD
                    );

            System.out.println(
                    "[DB] Connected Successfully"
            );

            return con;

        } catch (Exception e) {

            e.printStackTrace();
        }

        return null;
    }
}
