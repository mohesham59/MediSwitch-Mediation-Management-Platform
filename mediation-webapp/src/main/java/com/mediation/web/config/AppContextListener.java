package com.mediation.web.config;

import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;

public class AppContextListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        ServletContext ctx = sce.getServletContext();

        // Environment variables take priority (Render / Docker),
        // fall back to web.xml context-params for local Tomcat.
        String url = getConfig("DB_URL", "db.url", ctx);
        String user = getConfig("DB_USERNAME", "db.username", ctx);
        String pass = getConfig("DB_PASSWORD", "db.password", ctx);

        ctx.log("[MediFlow] Connecting to DB: " + url + " as " + user);

        try {
            DatabaseConfig.init(url, user, pass);
            ctx.log("[MediFlow] DB pool initialised OK.");
        } catch (Exception e) {
            ctx.log("[MediFlow] ERROR — DB init failed: " + e.getMessage(), e);
            ctx.setAttribute("dbError", e.getMessage());
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        try {
            DatabaseConfig.close();
        } catch (Exception ignored) {
        }
    }

    private String getConfig(String envKey, String paramKey, ServletContext ctx) {
        String envVal = System.getenv(envKey);
        if (envVal != null && !envVal.isBlank()) {
            return envVal;
        }
        return ctx.getInitParameter(paramKey);
    }
}
