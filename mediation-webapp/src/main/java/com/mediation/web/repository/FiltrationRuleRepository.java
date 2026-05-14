package com.mediation.web.repository;

import com.mediation.web.config.DatabaseConfig;
import com.mediation.web.model.FiltrationRule;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class FiltrationRuleRepository {

    public List<FiltrationRule> findByMediationRuleId(int mediationRuleId) throws SQLException {
        String sql = "SELECT * FROM filtration_rules WHERE mediation_rule_id = ? ORDER BY id";
        List<FiltrationRule> list = new ArrayList<>();
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, mediationRuleId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    public List<FiltrationRule> findActiveByMediationRuleId(int mediationRuleId) throws SQLException {
        String sql = "SELECT * FROM filtration_rules WHERE mediation_rule_id = ? AND is_active = TRUE ORDER BY id";
        List<FiltrationRule> list = new ArrayList<>();
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, mediationRuleId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    public void save(FiltrationRule rule) throws SQLException {
        String sql = """
            INSERT INTO filtration_rules (mediation_rule_id, rule_type, field_name, value, is_active)
            VALUES (?, ?, ?, ?, TRUE)
            """;
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, rule.getMediationRuleId());
            ps.setString(2, rule.getRuleType());
            ps.setString(3, rule.getFieldName());
            ps.setString(4, rule.getValue());
            ps.executeUpdate();
        }
    }

    public void update(FiltrationRule rule) throws SQLException {
        String sql = """
            UPDATE filtration_rules
            SET rule_type = ?, field_name = ?, value = ?, is_active = ?
            WHERE id = ?
            """;
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, rule.getRuleType());
            ps.setString(2, rule.getFieldName());
            ps.setString(3, rule.getValue());
            ps.setBoolean(4, rule.isActive());
            ps.setInt(5, rule.getId());
            ps.executeUpdate();
        }
    }

    public void setActive(int id, boolean active) throws SQLException {
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "UPDATE filtration_rules SET is_active = ? WHERE id = ?")) {
            ps.setBoolean(1, active);
            ps.setInt(2, id);
            ps.executeUpdate();
        }
    }

    public void delete(int id) throws SQLException {
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "DELETE FROM filtration_rules WHERE id = ?")) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    /** Deletes all filtration rules belonging to a mediation rule. */
    public void deleteByMediationRuleId(int mediationRuleId) throws SQLException {
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "DELETE FROM filtration_rules WHERE mediation_rule_id = ?")) {
            ps.setInt(1, mediationRuleId);
            ps.executeUpdate();
        }
    }

    /** Returns all blocked numbers from the blocked_numbers table. */
    public List<String> findAllBlockedNumbers() throws SQLException {
        List<String> numbers = new ArrayList<>();
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT number FROM blocked_numbers ORDER BY number");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) numbers.add(rs.getString("number"));
        }
        return numbers;
    }

    public int countByMediationRuleId(int mediationRuleId) throws SQLException {
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT COUNT(*) FROM filtration_rules WHERE mediation_rule_id = ?")) {
            ps.setInt(1, mediationRuleId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    private FiltrationRule map(ResultSet rs) throws SQLException {
        FiltrationRule f = new FiltrationRule();
        f.setId(rs.getInt("id"));
        f.setMediationRuleId(rs.getInt("mediation_rule_id"));
        f.setRuleType(rs.getString("rule_type"));
        f.setFieldName(rs.getString("field_name"));
        f.setValue(rs.getString("value"));
        f.setActive(rs.getBoolean("is_active"));
        return f;
    }
}
