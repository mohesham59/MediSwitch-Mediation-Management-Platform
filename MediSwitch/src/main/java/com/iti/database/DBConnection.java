package com.iti.database;
import java.sql.Connection;
import java.sql.DriverManager;
/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */

/**
 *
 * @author mohesham
 */
public class DBConnection {
        private static final String URL = "jdbc:postgresql://neondb_owner:npg_jlo1yt0MmzFU@ep-round-wave-an8ct2rt-pooler.c-6.us-east-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require";    
        private static final String USER = "neondb_owner";
    private static final String PASSWORD = "npg_jlo1yt0MmzFU";

    public static Connection getConnection() {
        Connection con = null;
        try {
            Class.forName("org.postgresql.Driver");
            con = DriverManager.getConnection(URL, USER, PASSWORD);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return con;
    }
}