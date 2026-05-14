package com.mediation.web.servlet;

import com.mediation.web.repository.BlockedNumberRepository;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;

public class BlockedNumbersServlet extends HttpServlet {

    private final BlockedNumberRepository repo = new BlockedNumberRepository();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        try {
            if (pathInfo != null && pathInfo.startsWith("/delete/")) {
                int id = Integer.parseInt(pathInfo.substring(8));
                repo.delete(id);
                resp.sendRedirect(req.getContextPath() + "/blocked?success=deleted");
            } else {
                req.setAttribute("numbers", repo.findAll());
                req.getRequestDispatcher("/WEB-INF/views/blocked.jsp").forward(req, resp);
            }
        } catch (Exception e) {
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/blocked.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            repo.save(req.getParameter("number"), req.getParameter("description"));
            resp.sendRedirect(req.getContextPath() + "/blocked?success=added");
        } catch (Exception e) {
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/blocked.jsp").forward(req, resp);
        }
    }
}
