package com.mediation.web.servlet;

import com.mediation.web.repository.AdminRepository;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import org.mindrot.jbcrypt.BCrypt;
import java.io.IOException;

public class AdminsServlet extends HttpServlet {

    private final AdminRepository repo = new AdminRepository();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        try {
            if (pathInfo != null && pathInfo.startsWith("/delete/")) {
                int id = Integer.parseInt(pathInfo.substring(8));
                // Prevent deleting yourself
                String current = (String) req.getSession().getAttribute("admin");
                repo.findAll().stream()
                    .filter(a -> a.getId() == id && !a.getUsername().equals(current))
                    .findFirst()
                    .ifPresent(a -> { try { repo.delete(id); } catch (Exception ignored) {} });
                resp.sendRedirect(req.getContextPath() + "/admins?success=deleted");
            } else if (pathInfo != null && pathInfo.startsWith("/toggle/")) {
                int id = Integer.parseInt(pathInfo.substring(8));
                repo.findAll().stream().filter(a -> a.getId() == id).findFirst().ifPresent(a -> {
                    try { repo.setActive(id, !a.isActive()); } catch (Exception ignored) {}
                });
                resp.sendRedirect(req.getContextPath() + "/admins");
            } else {
                req.setAttribute("admins", repo.findAll());
                req.getRequestDispatcher("/WEB-INF/views/admins.jsp").forward(req, resp);
            }
        } catch (Exception e) {
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/admins.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            String username = req.getParameter("username");
            String password = req.getParameter("password");
            String hash = BCrypt.hashpw(password, BCrypt.gensalt(12));
            repo.save(username, hash);
            resp.sendRedirect(req.getContextPath() + "/admins?success=created");
        } catch (Exception e) {
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/admins.jsp").forward(req, resp);
        }
    }
}
