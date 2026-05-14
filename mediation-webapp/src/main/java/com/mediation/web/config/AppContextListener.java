package com.mediation.web.config;

import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;

public class AppContextListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        ServletContext ctx = sce.getServletContext();
        String url  = ctx.getInitParameter("db.url");
        String user = ctx.getInitParameter("db.username");
        String pass = ctx.getInitParameter("db.password");

        try {
            DatabaseConfig.init(url, user, pass);
            ctx.log("[MediFlow] Database pool initialised successfully.");
        } catch (Exception e) {
            // Log the error but do NOT re-throw — a startup crash causes Tomcat
            // to mark the entire app as failed (404 on every URL).
            ctx.log("[MediFlow] WARNING: Database pool failed to initialise: " + e.getMessage()
                    + " — Fix db.url/username/password in web.xml and redeploy.");
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        try {
            DatabaseConfig.close();
        } catch (Exception ignored) {}
    }
}
