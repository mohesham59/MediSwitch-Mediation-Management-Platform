package com.iti.router;

import com.iti.database.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class RouterService {

    public List<String> getDestinations(
            String sourceName
    ) {

        List<String> destinations
                = new ArrayList<>();

        try (Connection con
                = DBConnection.getConnection()) {

            String sql = """
                    SELECT d.name AS destination
                    FROM mediation_rules mr
                    JOIN nodes s
                    ON mr.source_node_id = s.id
                    JOIN nodes d
                    ON mr.destination_node_id = d.id
                    WHERE s.name = ?
                    AND mr.is_active = true
                    """;

            PreparedStatement ps
                    = con.prepareStatement(sql);

            ps.setString(1, sourceName);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                destinations.add(
                        rs.getString("destination")
                );
            }

        } catch (Exception e) {
            throw new RuntimeException("Router DB failed", e);
        }

        return destinations;
    }
}
