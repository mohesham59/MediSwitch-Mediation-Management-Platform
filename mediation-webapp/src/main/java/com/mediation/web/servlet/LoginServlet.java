package com.mediation.web.servlet;

import com.mediation.web.model.Admin;
import com.mediation.web.repository.AdminRepository;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.Optional;

public class LoginServlet extends HttpServlet {

    private final AdminRepository adminRepo = new AdminRepository();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("admin") != null) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }
        req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String username = req.getParameter("username");
        String password = req.getParameter("password");

        try {
            Optional<Admin> adminOpt = adminRepo.findByUsername(username);
            if (adminOpt.isPresent() && checkPassword(password, adminOpt.get().getPasswordHash())) {
                HttpSession session = req.getSession(true);
                session.setAttribute("admin", adminOpt.get().getUsername());
                session.setMaxInactiveInterval(1800);
                resp.sendRedirect(req.getContextPath() + "/dashboard");
                return;
            }
            req.setAttribute("error", "Invalid username or password.");
        } catch (Exception e) {
            req.setAttribute("error", "Database error: " + e.getMessage()
                    + " — check your db.url/username/password in web.xml.");
        }

        req.setAttribute("username", username);
        req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
    }

    private boolean checkPassword(String raw, String stored) {
        if (stored == null || raw == null) return false;
        if (stored.startsWith("$2")) {
            try { return org.mindrot.jbcrypt.BCrypt.checkpw(raw, stored); }
            catch (Exception e) { return false; }
        }
        return raw.equals(stored); // plain text fallback (dev seed)
    }
}
