package com.mediation.web.repository;

import com.mediation.web.config.DatabaseConfig;
import com.mediation.web.model.BlockedNumber;

import java.sql.*;
import java.util.*;

public class BlockedNumberRepository {

    public List<BlockedNumber> findAll() throws SQLException {
        List<BlockedNumber> list = new ArrayList<>();
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement("SELECT * FROM blocked_numbers ORDER BY number");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(map(rs));
        }
        return list;
    }

    public void save(String number, String description) throws SQLException {
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement(
                 "INSERT INTO blocked_numbers (number, description) VALUES (?,?)")) {
            ps.setString(1, number);
            ps.setString(2, description);
            ps.executeUpdate();
        }
    }

    public void delete(int id) throws SQLException {
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement("DELETE FROM blocked_numbers WHERE id=?")) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    private BlockedNumber map(ResultSet rs) throws SQLException {
        BlockedNumber b = new BlockedNumber();
        b.setId(rs.getInt("id"));
        b.setNumber(rs.getString("number"));
        b.setDescription(rs.getString("description"));
        return b;
    }
}
