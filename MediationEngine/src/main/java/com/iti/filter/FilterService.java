package com.iti.filter;

import com.iti.database.DBConnection;
import com.iti.model.CDRRecord;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class FilterService {

    public boolean isAllowed(CDRRecord record) {

        try (Connection con
                = DBConnection.getConnection()) {

            String sql = """
                    SELECT rule_type,
                           field_name,
                           value
                    FROM filtration_rules
                    WHERE is_active = true
                    """;

            PreparedStatement ps
                    = con.prepareStatement(sql);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                String ruleType
                        = rs.getString("rule_type");

                String fieldName
                        = rs.getString("field_name");

                String value
                        = rs.getString("value");

                String recordValue
                        = record.get(fieldName);

                if (recordValue == null) {
                    continue;
                }

                switch (ruleType) {

                    case "FIELD_EQUALS":

                        if (recordValue.equals(value)) {
                            return false;
                        }

                        break;

                    case "FIELD_LESS_THAN":

                        double r
                                = Double.parseDouble(recordValue);

                        double v
                                = Double.parseDouble(value);

                        if (r < v) {
                            return false;
                        }

                        break;

                    case "REGEX_MATCH":

                        if (recordValue.matches(value)) {
                            return false;
                        }

                        break;
                }
            }

        } catch (Exception e) {
            throw new RuntimeException("Filter DB failed", e);
        }

        return true;
    }
}
