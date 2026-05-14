package com.mediation.web.repository;

import com.mediation.web.config.DatabaseConfig;
import com.mediation.web.model.Admin;

import java.sql.*;
import java.util.*;

public class AdminRepository {

    public Optional<Admin> findByUsername(String username) throws SQLException {
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement(
                 "SELECT * FROM admins WHERE username=? AND is_active=TRUE")) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return Optional.of(map(rs));
            }
        }
        return Optional.empty();
    }

    public List<Admin> findAll() throws SQLException {
        List<Admin> list = new ArrayList<>();
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement("SELECT * FROM admins ORDER BY id");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(map(rs));
        }
        return list;
    }

    public void save(String username, String passwordHash) throws SQLException {
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement(
                 "INSERT INTO admins (username, password_hash, is_active) VALUES (?,?,TRUE)")) {
            ps.setString(1, username);
            ps.setString(2, passwordHash);
            ps.executeUpdate();
        }
    }

    public void setActive(int id, boolean active) throws SQLException {
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement(
                 "UPDATE admins SET is_active=? WHERE id=?")) {
            ps.setBoolean(1, active);
            ps.setInt(2, id);
            ps.executeUpdate();
        }
    }

    public void delete(int id) throws SQLException {
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement("DELETE FROM admins WHERE id=?")) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    private Admin map(ResultSet rs) throws SQLException {
        Admin a = new Admin();
        a.setId(rs.getInt("id"));
        a.setUsername(rs.getString("username"));
        a.setPasswordHash(rs.getString("password_hash"));
        a.setActive(rs.getBoolean("is_active"));
        return a;
    }
}
