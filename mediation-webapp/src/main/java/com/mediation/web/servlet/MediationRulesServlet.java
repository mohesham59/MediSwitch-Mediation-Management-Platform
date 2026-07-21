package com.mediation.web.servlet;

import com.mediation.web.model.FiltrationRule;
import com.mediation.web.repository.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;

public class MediationRulesServlet extends HttpServlet {

    private final MediationRuleRepository ruleRepo = new MediationRuleRepository();
    private final NodeRepository          nodeRepo = new NodeRepository();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String pathInfo = req.getPathInfo();

        try {
            if (pathInfo == null || pathInfo.equals("/")) {
                req.setAttribute("rules", ruleRepo.findAll());
                req.getRequestDispatcher("/WEB-INF/views/rules.jsp").forward(req, resp);

            } else if (pathInfo.equals("/new")) {
                req.setAttribute("upstreamNodes",   nodeRepo.findUpstream());
                req.setAttribute("downstreamNodes", nodeRepo.findDownstream());
                req.getRequestDispatcher("/WEB-INF/views/rule-form.jsp").forward(req, resp);

            } else if (pathInfo.startsWith("/view/")) {
                int id = Integer.parseInt(pathInfo.substring(6));
                ruleRepo.findById(id).ifPresent(r -> req.setAttribute("rule", r));
                req.setAttribute("upstreamNodes",   nodeRepo.findUpstream());
                req.setAttribute("downstreamNodes", nodeRepo.findDownstream());
                req.getRequestDispatcher("/WEB-INF/views/rule-detail.jsp").forward(req, resp);

            } else if (pathInfo.startsWith("/edit/")) {
                int id = Integer.parseInt(pathInfo.substring(6));
                ruleRepo.findById(id).ifPresent(r -> req.setAttribute("rule", r));
                req.setAttribute("upstreamNodes",   nodeRepo.findUpstream());
                req.setAttribute("downstreamNodes", nodeRepo.findDownstream());
                req.getRequestDispatcher("/WEB-INF/views/rule-form.jsp").forward(req, resp);

            } else if (pathInfo.startsWith("/toggle/")) {
                int id = Integer.parseInt(pathInfo.substring(8));
                ruleRepo.findById(id).ifPresent(r -> {
                    try { ruleRepo.setActive(id, !r.isActive()); } catch (Exception ignored) {}
                });
                resp.sendRedirect(req.getContextPath() + "/rules");

            } else if (pathInfo.startsWith("/delete/")) {
                int id = Integer.parseInt(pathInfo.substring(8));
                ruleRepo.delete(id);
                resp.sendRedirect(req.getContextPath() + "/rules?success=deleted");

            } else if (pathInfo.startsWith("/filter/delete/")) {
                int id = Integer.parseInt(pathInfo.substring(15));
                ruleRepo.deleteFiltrationRule(id);
                String referer = req.getHeader("Referer");
                resp.sendRedirect(referer != null ? referer : req.getContextPath() + "/rules");
            }
        } catch (Exception e) {
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/rules.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        try {
            if (pathInfo != null && pathInfo.equals("/new")) {
                int srcId  = Integer.parseInt(req.getParameter("sourceNodeId"));
                int dstId  = Integer.parseInt(req.getParameter("destinationNodeId"));
                ruleRepo.save(srcId, dstId);
                resp.sendRedirect(req.getContextPath() + "/rules?success=created");

            } else if (pathInfo != null && pathInfo.startsWith("/edit/")) {
                int id     = Integer.parseInt(pathInfo.substring(6));
                int srcId  = Integer.parseInt(req.getParameter("sourceNodeId"));
                int dstId  = Integer.parseInt(req.getParameter("destinationNodeId"));
                ruleRepo.update(id, srcId, dstId);
                resp.sendRedirect(req.getContextPath() + "/rules/view/" + id + "?success=updated");

            } else if (pathInfo != null && pathInfo.startsWith("/filter/add/")) {
                int ruleId = Integer.parseInt(pathInfo.substring(12));
                FiltrationRule fr = new FiltrationRule();
                fr.setMediationRuleId(ruleId);
                fr.setRuleType(req.getParameter("ruleType"));
                fr.setFieldName(req.getParameter("fieldName"));
                String val = req.getParameter("value");
                fr.setValue((val == null || val.isBlank()) ? null : val);
                ruleRepo.saveFiltrationRule(fr);
                resp.sendRedirect(req.getContextPath() + "/rules/view/" + ruleId + "?success=filter_added");
            }
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/rules?error=" + e.getMessage());
        }
    }
}
