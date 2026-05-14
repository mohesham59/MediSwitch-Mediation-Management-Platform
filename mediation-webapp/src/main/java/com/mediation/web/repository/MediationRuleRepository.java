package com.mediation.web.repository;

import com.mediation.web.config.DatabaseConfig;
import com.mediation.web.model.FiltrationRule;
import com.mediation.web.model.MediationRule;

import java.sql.*;
import java.util.*;

public class MediationRuleRepository {

    public List<MediationRule> findAll() throws SQLException {
        String sql = """
            SELECT mr.*, sn.name sn_name, sn.node_type sn_type,
                         dn.name dn_name, dn.node_type dn_type
            FROM mediation_rules mr
            JOIN nodes sn ON sn.id = mr.source_node_id
            JOIN nodes dn ON dn.id = mr.destination_node_id
            ORDER BY mr.id
            """;
        List<MediationRule> list = new ArrayList<>();
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapWithNodes(rs));
        }
        return list;
    }

    public Optional<MediationRule> findById(int id) throws SQLException {
        String sql = """
            SELECT mr.*, sn.name sn_name, sn.node_type sn_type,
                         dn.name dn_name, dn.node_type dn_type
            FROM mediation_rules mr
            JOIN nodes sn ON sn.id = mr.source_node_id
            JOIN nodes dn ON dn.id = mr.destination_node_id
            WHERE mr.id=?
            """;
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    MediationRule rule = mapWithNodes(rs);
                    rule.setFiltrationRules(findFiltrationRules(id));
                    return Optional.of(rule);
                }
            }
        }
        return Optional.empty();
    }

    public List<FiltrationRule> findFiltrationRules(int mediationRuleId) throws SQLException {
        List<FiltrationRule> list = new ArrayList<>();
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement(
                 "SELECT * FROM filtration_rules WHERE mediation_rule_id=? ORDER BY id")) {
            ps.setInt(1, mediationRuleId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapFiltration(rs));
            }
        }
        return list;
    }

    public void save(int sourceId, int destId) throws SQLException {
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement(
                 "INSERT INTO mediation_rules (source_node_id, destination_node_id, is_active) VALUES (?,?,TRUE)")) {
            ps.setInt(1, sourceId);
            ps.setInt(2, destId);
            ps.executeUpdate();
        }
    }

    public void setActive(int id, boolean active) throws SQLException {
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement(
                 "UPDATE mediation_rules SET is_active=? WHERE id=?")) {
            ps.setBoolean(1, active);
            ps.setInt(2, id);
            ps.executeUpdate();
        }
    }

    public void delete(int id) throws SQLException {
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement(
                 "DELETE FROM mediation_rules WHERE id=?")) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    public void saveFiltrationRule(FiltrationRule r) throws SQLException {
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement(
                 "INSERT INTO filtration_rules (mediation_rule_id,rule_type,field_name,value,is_active) VALUES (?,?,?,?,TRUE)")) {
            ps.setInt(1, r.getMediationRuleId());
            ps.setString(2, r.getRuleType());
            ps.setString(3, r.getFieldName());
            ps.setString(4, r.getValue());
            ps.executeUpdate();
        }
    }

    public void deleteFiltrationRule(int id) throws SQLException {
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement(
                 "DELETE FROM filtration_rules WHERE id=?")) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    public int countActive() throws SQLException {
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement(
                 "SELECT COUNT(*) FROM mediation_rules WHERE is_active=TRUE");
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    private MediationRule mapWithNodes(ResultSet rs) throws SQLException {
        MediationRule r = new MediationRule();
        r.setId(rs.getInt("id"));
        r.setSourceNodeId(rs.getInt("source_node_id"));
        r.setDestinationNodeId(rs.getInt("destination_node_id"));
        r.setActive(rs.getBoolean("is_active"));
        r.setSourceName(rs.getString("sn_name"));
        r.setSourceType(rs.getString("sn_type"));
        r.setDestinationName(rs.getString("dn_name"));
        r.setDestinationType(rs.getString("dn_type"));
        return r;
    }

    private FiltrationRule mapFiltration(ResultSet rs) throws SQLException {
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
