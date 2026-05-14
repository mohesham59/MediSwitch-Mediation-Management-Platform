package com.mediation.web.repository;

import com.mediation.web.config.DatabaseConfig;
import com.mediation.web.model.Node;

import java.sql.*;
import java.util.*;

public class NodeRepository {

    public List<Node> findAll() throws SQLException {
        List<Node> list = new ArrayList<>();
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement("SELECT * FROM nodes ORDER BY node_type, name");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(map(rs));
        }
        return list;
    }

    public List<Node> findUpstream() throws SQLException {
        List<Node> list = new ArrayList<>();
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement("SELECT * FROM nodes WHERE node_type='UPSTREAM' ORDER BY name");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(map(rs));
        }
        return list;
    }

    public List<Node> findDownstream() throws SQLException {
        List<Node> list = new ArrayList<>();
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement("SELECT * FROM nodes WHERE node_type='DOWNSTREAM' ORDER BY name");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(map(rs));
        }
        return list;
    }

    public Optional<Node> findById(int id) throws SQLException {
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement("SELECT * FROM nodes WHERE id=?")) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return Optional.of(map(rs));
            }
        }
        return Optional.empty();
    }

    public void save(Node n) throws SQLException {
        String sql = "INSERT INTO nodes (name,node_type,protocol,ip,port,username,password_hash,remote_path,cdr_format,is_active) VALUES (?,?,?,?,?,?,?,?,?,?)";
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, n.getName());
            ps.setString(2, n.getNodeType());
            ps.setString(3, n.getProtocol());
            ps.setString(4, n.getIp());
            ps.setInt(5, n.getPort());
            ps.setString(6, n.getUsername());
            ps.setString(7, n.getPasswordHash());
            ps.setString(8, n.getRemotePath());
            ps.setString(9, n.getCdrFormat());
            ps.setBoolean(10, n.isActive());
            ps.executeUpdate();
        }
    }

    public void update(Node n) throws SQLException {
        String sql = "UPDATE nodes SET name=?,node_type=?,protocol=?,ip=?,port=?,username=?,password_hash=?,remote_path=?,cdr_format=?,is_active=? WHERE id=?";
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, n.getName());
            ps.setString(2, n.getNodeType());
            ps.setString(3, n.getProtocol());
            ps.setString(4, n.getIp());
            ps.setInt(5, n.getPort());
            ps.setString(6, n.getUsername());
            ps.setString(7, n.getPasswordHash());
            ps.setString(8, n.getRemotePath());
            ps.setString(9, n.getCdrFormat());
            ps.setBoolean(10, n.isActive());
            ps.setInt(11, n.getId());
            ps.executeUpdate();
        }
    }

    public void delete(int id) throws SQLException {
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement("DELETE FROM nodes WHERE id=?")) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    public Map<String, Integer> getCounts() throws SQLException {
        Map<String, Integer> m = new HashMap<>();
        try (Connection c = DatabaseConfig.getConnection();
             PreparedStatement ps = c.prepareStatement(
                 "SELECT node_type, COUNT(*) cnt FROM nodes GROUP BY node_type");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) m.put(rs.getString("node_type"), rs.getInt("cnt"));
        }
        return m;
    }

    private Node map(ResultSet rs) throws SQLException {
        Node n = new Node();
        n.setId(rs.getInt("id"));
        n.setName(rs.getString("name"));
        n.setNodeType(rs.getString("node_type"));
        n.setProtocol(rs.getString("protocol"));
        n.setIp(rs.getString("ip"));
        n.setPort(rs.getInt("port"));
        n.setUsername(rs.getString("username"));
        n.setPasswordHash(rs.getString("password_hash"));
        n.setRemotePath(rs.getString("remote_path"));
        n.setCdrFormat(rs.getString("cdr_format"));
        n.setActive(rs.getBoolean("is_active"));
        return n;
    }
}
