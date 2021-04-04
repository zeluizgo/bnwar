package com.citibank.bon.servlet;
import javax.servlet.*;
import javax.servlet.http.*;
import com.citibank.bon.util.Resources;
import com.citibank.bon.bean.CurrentParameters;
import com.citibank.bon.bean.RossSession;
import com.citibank.bon.sql.BonusStruct;
import java.util.Hashtable;
import java.util.Enumeration;
import java.sql.*;

public class CheckUpdate extends BaseServlet
{
  public void doPost(HttpServletRequest request, HttpServletResponse response)
	  throws ServletException, java.io.IOException
  {
    boolean ret = true;
    setSession(request);setModule(RossSession.REV_REVISAR);
    if ( !verSession(request,response) ) {
      return;
    }
    RequestDispatcher dispatcher;
    if (request.getParameter("list_selected.x") != null) {
      Connection conn = null;
      PreparedStatement ps = null;
      ResultSet rs = null;
      try {
        logDebug("list selected");
        int iCount;
        Hashtable hashGroup = new Hashtable();
        Hashtable hashDivision = new Hashtable();
        Enumeration enumGroup;
        String[] sParent = request.getParameterValues("chk_div_code_parent");
        String[] sGroup = request.getParameterValues("chk_div_code_group");
        String[] sVirtual = request.getParameterValues("strct_bonus_div_code_virtual");
        String[] sDivision = request.getParameterValues("chk_div_code_division");

        conn = getConnection();
        CurrentParameters currentParameters = Resources.getCurrentParameters(getServletContext());

        ps = conn.prepareStatement(BonusStruct.getQuery(BonusStruct.GROUP_BY_YEAR_AND_PARENT));
        ps.setLong(1,Long.parseLong(currentParameters.getYearRef()));
        ps.setLong(2,Long.parseLong(currentParameters.getYearSeq()));
        if ( sParent != null ) {
          for ( iCount = 0 ; iCount < sParent.length ; iCount ++ ) {
            ps.setString(3,sParent[iCount]);
            rs = ps.executeQuery();
            while(rs.next()) {
              hashGroup.put(rs.getString("STRCT_BONUS_DIV_CODE"),"");
            }
            rs.close();
          }
        }

        if ( sVirtual != null ) {
          for ( iCount = 0 ; iCount < sVirtual.length ; iCount ++ ) {
            ps.setString(3,sVirtual[iCount]);
            rs = ps.executeQuery();
            while(rs.next()) {
              hashGroup.put(rs.getString("STRCT_BONUS_DIV_CODE"),"");
            }
            rs.close();
          }
        }
        ps.close();

        if ( sGroup != null ) {
          for ( iCount = 0 ; iCount < sGroup.length ; iCount ++ ) {
            hashGroup.put(sGroup[iCount],"");
          }
        }
        enumGroup = hashGroup.keys();

        ps = conn.prepareStatement(BonusStruct.getQuery(BonusStruct.DIVISION_BY_YEAR_AND_GROUP));
        ps.setLong(1,Long.parseLong(currentParameters.getYearRef()));
        ps.setLong(2,Long.parseLong(currentParameters.getYearSeq()));
        while ( enumGroup.hasMoreElements()) {
          ps.setString(3,(String)enumGroup.nextElement());
          rs = ps.executeQuery();
          while(rs.next()) {
            hashDivision.put(rs.getString("STRCT_BONUS_DIV_CODE"),"");
          }
          rs.close();
        }
        ps.close();

        if ( sDivision != null ) {
          for ( iCount = 0 ; iCount < sDivision.length ; iCount ++ ) {
            hashDivision.put(sDivision[iCount],"");
          }
        }
        request.setAttribute("struct_bonus_div_code",hashDivision.keys());
      }catch (NullPointerException exc){
        logError("NullPointer",exc);
        dispatcher = getServletContext().getRequestDispatcher("/error.jsp");
        request.setAttribute("lastException",exc);
        dispatcher.forward(request, response);
        ret = false;
      }catch (NumberFormatException exc){
        logError("NumberFormat",exc);
        dispatcher = getServletContext().getRequestDispatcher("/error.jsp");
        request.setAttribute("lastException",exc);
        dispatcher.forward(request, response);
        ret = false;
      }catch (SQLException exc){
        try {
    			if (conn != null) {
        		conn.rollback();
        	}
        } catch(SQLException exc2) {}

        logError("SQL error",exc);
        dispatcher = getServletContext().getRequestDispatcher("/error.jsp");
        request.setAttribute("lastException",exc);
        dispatcher.forward(request, response);
        ret = false;
      }
      finally {
        try {
    			if (ps != null) {
        		ps.close();
        	}
        } catch(SQLException exc) {
    			logError("SQLError",exc);
    		}
        try {
    			if (conn != null) {
        		conn.close();
        	}
        } catch(SQLException exc) {
    			logError("SQLError",exc);
    		}
      }
      if ( ret ) {
        dispatcher = getServletContext().getRequestDispatcher("/check_detail.jsp");
        dispatcher.forward(request, response);
      }
    } else if (request.getParameter("repprove.x") != null) {
      logDebug("reprove selected");
      request.setAttribute("action","reprovado(s)");
      dispatcher = getServletContext().getRequestDispatcher("/check_reason.jsp");
      dispatcher.forward(request, response);
    } else if (request.getParameter("approve.x") != null) {
      logDebug("aprove selected");
      request.setAttribute("action","aprovado(s)");
      Connection conn = null;
      CallableStatement cs = null;
      logAudit(TABLE_POOL,AUDIT_UPDATE);
      int iCount;
      try {
        CurrentParameters currentParameters = Resources.getCurrentParameters(getServletContext());
        String[] strct_bonus_div_code_parent   = request.getParameterValues("chk_div_code_parent");
        String[] strct_bonus_div_code_group    = request.getParameterValues("chk_div_code_group");
        String[] strct_bonus_div_code_division = request.getParameterValues("chk_div_code_division");
        String[] strct_bonus_div_code_virtual  = request.getParameterValues("chk_div_code_virtual");

        conn = getConnection();

        cs = conn.prepareCall("{call kbn_check.pbn_approve(?,?,?,?)}");

        cs.setInt(1,Integer.parseInt(currentParameters.getYearRef()));
        cs.setInt(2,Integer.parseInt(currentParameters.getYearSeq()));
        cs.setInt(3,currentParameters.getPoolSeq());

        if (strct_bonus_div_code_division != null) {
          for ( iCount = 0 ; iCount < strct_bonus_div_code_division.length ; iCount ++ ) {
            logDebug("Approve->" + strct_bonus_div_code_division[iCount]);
            cs.setString(4,strct_bonus_div_code_division[iCount]);
            cs.execute();
          }
        }
        if (strct_bonus_div_code_group != null) {
          for ( iCount = 0 ; iCount < strct_bonus_div_code_group.length ; iCount ++ ) {
            logDebug("Approve->" + strct_bonus_div_code_group[iCount]);
            cs.setString(4,strct_bonus_div_code_group[iCount]);
            cs.execute();
          }
        }
        if (strct_bonus_div_code_virtual != null) {
          for ( iCount = 0 ; iCount < strct_bonus_div_code_virtual.length ; iCount ++ ) {
            logDebug("Approve->" + strct_bonus_div_code_virtual[iCount]);
            cs.setString(4,strct_bonus_div_code_virtual[iCount]);
            cs.execute();
          }
        }
        if (strct_bonus_div_code_parent != null) {
          for ( iCount = 0 ; iCount < strct_bonus_div_code_parent.length ; iCount ++ ) {
            logDebug("Approve->" + strct_bonus_div_code_parent[iCount]);
            cs.setString(4,strct_bonus_div_code_parent[iCount]);
            cs.execute();
          }
        }
        cs.close();
        conn.commit();
      }catch (NullPointerException exc){
        logError("NullPointer",exc);
        dispatcher = getServletContext().getRequestDispatcher("/error.jsp");
        request.setAttribute("lastException",exc);
        dispatcher.forward(request, response);
        ret = false;
      }catch (NumberFormatException exc){
        logError("NumberFormat",exc);
        dispatcher = getServletContext().getRequestDispatcher("/error.jsp");
        request.setAttribute("lastException",exc);
        dispatcher.forward(request, response);
        ret = false;
      }catch (SQLException exc){
        try {
    			if (conn != null) {
        		conn.rollback();
        	}
        } catch(SQLException exc2) {}

        logError("SQL error",exc);
        dispatcher = getServletContext().getRequestDispatcher("/error.jsp");
        request.setAttribute("lastException",exc);
        dispatcher.forward(request, response);
        ret = false;
      }
      finally {
        try {
    			if (cs != null) {
        		cs.close();
        	}
        } catch(SQLException exc) {
    			logError("SQLError",exc);
    		}
        try {
    			if (conn != null) {
        		conn.close();
        	}
        } catch(SQLException exc) {
    			logError("SQLError",exc);
    		}
      }
      Resources.reloadCurrentParameters(getServletContext());
      if ( ret ) {
        request.setAttribute("target","check_list.jsp");
        request.setAttribute("module","Pool");
        dispatcher = getServletContext().getRequestDispatcher("/finish.jsp");
        dispatcher.forward(request, response);
      }
    }
  }
}