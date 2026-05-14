package com.mediation.web.servlet;

import com.mediation.web.repository.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.Map;

public class DashboardServlet extends HttpServlet {

    private final NodeRepository          nodeRepo   = new NodeRepository();
    private final MediationRuleRepository ruleRepo   = new MediationRuleRepository();
    private final BlockedNumberRepository blockedRepo = new BlockedNumberRepository();
    private final AdminRepository         adminRepo  = new AdminRepository();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // Redirect root to login if not authenticated
        String path = req.getServletPath();
        HttpSession session = req.getSession(false);
        if ((path.equals("/") || path.isEmpty()) && (session == null || session.getAttribute("admin") == null)) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            Map<String, Integer> nodeCounts = nodeRepo.getCounts();
            req.setAttribute("upstreamCount",   nodeCounts.getOrDefault("UPSTREAM", 0));
            req.setAttribute("downstreamCount", nodeCounts.getOrDefault("DOWNSTREAM", 0));
            req.setAttribute("activeRules",     ruleRepo.countActive());
            req.setAttribute("blockedCount",    blockedRepo.findAll().size());
            req.setAttribute("adminCount",      adminRepo.findAll().size());
            req.setAttribute("recentNodes",     nodeRepo.findAll());
        } catch (Exception e) {
            req.setAttribute("error", "Failed to load dashboard: " + e.getMessage());
        }
        req.getRequestDispatcher("/WEB-INF/views/dashboard.jsp").forward(req, resp);
    }
}
