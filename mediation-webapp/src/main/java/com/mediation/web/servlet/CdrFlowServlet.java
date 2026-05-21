package com.mediation.web.servlet;

import com.mediation.web.repository.NodeRepository;
import com.mediation.web.repository.MediationRuleRepository;
import com.mediation.web.repository.BlockedNumberRepository;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;

public class CdrFlowServlet extends HttpServlet {

    private final NodeRepository          nodeRepo    = new NodeRepository();
    private final MediationRuleRepository ruleRepo    = new MediationRuleRepository();
    private final BlockedNumberRepository blockedRepo = new BlockedNumberRepository();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            req.setAttribute("nodes",         nodeRepo.findAll());
            req.setAttribute("rules",         ruleRepo.findAll());
            req.setAttribute("blockedNumbers", blockedRepo.findAll());
        } catch (Exception e) {
            req.setAttribute("error", e.getMessage());
        }
        req.getRequestDispatcher("/WEB-INF/views/cdr-flow.jsp").forward(req, resp);
    }
}
