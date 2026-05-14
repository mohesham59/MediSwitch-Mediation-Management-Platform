package com.iti.model;

import java.util.HashMap;
import java.util.Map;

public class CDRRecord {

    private Map<String, String> data;

    public CDRRecord() {
        data = new HashMap<>();
    }

    public void put(String key, String value) {
        data.put(key, value);
    }

    public String get(String key) {
        return data.get(key);
    }

    public Map<String, String> getData() {
        return data;
    }
}