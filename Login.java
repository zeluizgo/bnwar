package com.citibank.bon.servlet;

import javax.servlet.*;
import javax.servlet.http.*;
import com.citibank.bon.util.Resources;
import com.citibank.bon.bean.RossSession;
import com.citibank.bon.bean.ManagerSession;
import com.modemmedia.br.util.Log;
import java.io.*;

public class Login
    extends BaseServlet {
  public void doGet(HttpServletRequest request, HttpServletResponse response) throws
      ServletException, java.io.IOException {

    RequestDispatcher dispatcher;

    this.getServletConfig().getServletContext().setAttribute("rodando", "sim");
    HttpSession session = request.getSession();

    RossSession ross = (RossSession) session.getAttribute("rossSession");
    // Se já existe o objeto RossSession no Session
    if (ross != null) {
      switch (ross.getScopeCode()) {
        case RossSession.ALL_SCOPE:
          dispatcher = getServletContext().getRequestDispatcher("/home.jsp");
          break;
        case RossSession.ADM_SCOPE:
          dispatcher = getServletContext().getRequestDispatcher("/home_adm.jsp");
          break;
        case RossSession.MGMT_SCOPE:
          dispatcher = getServletContext().getRequestDispatcher("/home_mgmt.jsp");
          break;
        default:
          dispatcher = getServletContext().getRequestDispatcher("/no_grant.jsp");
          break;
      }
      dispatcher.forward(request, response);
    }
    // se o objeto RossSession esta nulo na Session, inicia um novo e coloca na Session
    else {
      try {
        logDebug("Start RossSessionBean");
        ross = new RossSession();
        ross.init(getServletContext(), request);

        ManagerSession managerSession;
        if (ross.isSGSessionValid() ) {
          session.setAttribute("userId", ross.getUserId());
          session.setAttribute("rossSession", ross);
          switch (ross.getScopeCode()) {
            case RossSession.ALL_SCOPE:
              managerSession = new ManagerSession();
              managerSession.setServletContext(getServletContext());
              managerSession.reloadInfo(Integer.parseInt(ross.getUserId()));
              session.setAttribute("managerSession", managerSession);
              dispatcher = getServletContext().getRequestDispatcher("/home.jsp");
              break;
            case RossSession.ADM_SCOPE:
              dispatcher = getServletContext().getRequestDispatcher("/home_adm.jsp");
              break;
            case RossSession.MGMT_SCOPE:
              managerSession = new ManagerSession();
              managerSession.setServletContext(getServletContext());
              managerSession.reloadInfo(Integer.parseInt(ross.getUserId()));
              session.setAttribute("managerSession", managerSession);
              dispatcher = getServletContext().getRequestDispatcher("/home_mgmt.jsp");
              break;
            default:
              dispatcher = getServletContext().getRequestDispatcher("/no_grant.jsp");
              break;
          }
          dispatcher.forward(request, response);
          logDebug("end login");
        }
        else {
          logInfo("Invalid session:");
          String pathIndex = com.citibank.bon.util.Resources.getEnvVariable(
              "path.index", getServletContext());
          response.sendRedirect(pathIndex);
        }
      }
      catch (Exception exc) {
        dispatcher = getServletContext().getRequestDispatcher("/error.jsp");
        request.setAttribute("lastException",exc);
        dispatcher.forward(request, response);
      }
    }
    this.getServletConfig().getServletContext().setAttribute("rodando", "nao");
  }
}


