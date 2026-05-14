package com.mediation.web.servlet;

import com.mediation.web.model.Node;
import com.mediation.web.repository.NodeRepository;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.Optional;

public class NodesServlet extends HttpServlet {

    private final NodeRepository repo = new NodeRepository();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String pathInfo = req.getPathInfo();

        try {
            if (pathInfo == null || pathInfo.equals("/")) {
                // List all nodes
                req.setAttribute("nodes", repo.findAll());
                req.getRequestDispatcher("/WEB-INF/views/nodes.jsp").forward(req, resp);

            } else if (pathInfo.equals("/new")) {
                req.getRequestDispatcher("/WEB-INF/views/node-form.jsp").forward(req, resp);

            } else if (pathInfo.startsWith("/edit/")) {
                int id = Integer.parseInt(pathInfo.substring(6));
                Optional<Node> node = repo.findById(id);
                if (node.isEmpty()) { resp.sendRedirect(req.getContextPath() + "/nodes"); return; }
                req.setAttribute("node", node.get());
                req.getRequestDispatcher("/WEB-INF/views/node-form.jsp").forward(req, resp);

            } else if (pathInfo.startsWith("/delete/")) {
                int id = Integer.parseInt(pathInfo.substring(8));
                repo.delete(id);
                resp.sendRedirect(req.getContextPath() + "/nodes?success=deleted");
            }
        } catch (Exception e) {
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/nodes.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        try {
            Node node = buildFromRequest(req);
            if (pathInfo != null && pathInfo.startsWith("/edit/")) {
                node.setId(Integer.parseInt(pathInfo.substring(6)));
                // Keep existing password if field is blank
                if (node.getPasswordHash() == null || node.getPasswordHash().isBlank()) {
                    Optional<Node> existing = repo.findById(node.getId());
                    existing.ifPresent(n -> node.setPasswordHash(n.getPasswordHash()));
                }
                repo.update(node);
                resp.sendRedirect(req.getContextPath() + "/nodes?success=updated");
            } else {
                repo.save(node);
                resp.sendRedirect(req.getContextPath() + "/nodes?success=created");
            }
        } catch (Exception e) {
            req.setAttribute("error", e.getMessage());
            req.setAttribute("node", buildFromRequest(req));
            req.getRequestDispatcher("/WEB-INF/views/node-form.jsp").forward(req, resp);
        }
    }

    private Node buildFromRequest(HttpServletRequest req) {
        Node n = new Node();
        n.setName(req.getParameter("name"));
        n.setNodeType(req.getParameter("nodeType"));
        n.setProtocol(req.getParameter("protocol"));
        n.setIp(req.getParameter("ip"));
        n.setPort(Integer.parseInt(req.getParameter("port") != null ? req.getParameter("port") : "22"));
        n.setUsername(req.getParameter("username"));
        n.setPasswordHash(req.getParameter("password"));
        n.setRemotePath(req.getParameter("remotePath") != null ? req.getParameter("remotePath") : "/");
        String fmt = req.getParameter("cdrFormat");
        n.setCdrFormat((fmt == null || fmt.isBlank()) ? null : fmt);
        n.setActive("on".equals(req.getParameter("isActive")) || "true".equals(req.getParameter("isActive")));
        return n;
    }
}
