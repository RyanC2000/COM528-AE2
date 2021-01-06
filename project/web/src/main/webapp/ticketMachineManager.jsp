<%-- 
    Document   : ticketMachineManager
    Created on : 4 Jan 2021, 12:35:36
    Author     : ryanj
--%>

<%@page import="org.solent.com528.project.model.dto.Station"%>
<%@page import="org.solent.com528.project.model.dto.TicketMachine"%>
<%@page import="org.solent.com528.project.model.dao.StationDAO"%>
<%@page import="org.solent.com528.project.model.dao.TicketMachineDAO"%>
<%@page import="org.solent.com528.project.impl.web.WebObjectFactory"%>
<%@page import="org.solent.com528.project.model.service.ServiceFacade"%>

<%
    //SET UP ERROR MESSAGES
    String errorMessage = "";
    String message = "";

    //ACCESSING SERVICES
    ServiceFacade serviceFacade = (ServiceFacade) WebObjectFactory.getServiceFacade();
    TicketMachineDAO ticketMachineDAO = serviceFacade.getTicketMachineDAO();
    StationDAO stationDAO = serviceFacade.getStationDAO();

    //ACCESSING REQUEST PARAMETERS
    String actionStr = request.getParameter("action");
    String ticketMachineUuid = request.getParameter("ticketMachineUuid");
    String stationName = request.getParameter("stationName");
    String updateStation = request.getParameter("updateStation");
    String updateUUID = request.getParameter("updateUUID");

    TicketMachine ticketMachine = new TicketMachine();
    Station station = new Station();
    station.setName(stationName);
    ticketMachine.setUuid(ticketMachineUuid);
    ticketMachine.setStation(station);

    //CHECK OPERATIONS
    if ("updateUUID".equals(actionStr)) {
        if (updateUUID == null) {
            errorMessage = "updateUUID must be a parameter for updateUUID";
        } else {
            ticketMachine = ticketMachineDAO.findByUuid(ticketMachineUuid);
            if (updateUUID == null || updateUUID.isEmpty()) {
                errorMessage = "cannot update ticket machine with empty uuid";
            } else {
                if (ticketMachine == null) {
                    errorMessage = "Cannot update ticket machine. Cannot find ticket machine with uuid :  " + ticketMachineUuid;
                } else if (ticketMachineDAO.findByUuid(updateUUID) != null) {
                    errorMessage = "Cannot update ticket machine " + ticketMachineUuid + " because uuid already exists:  " + updateUUID;
                } else {
                    ticketMachine.setUuid(updateUUID);
                    ticketMachine = ticketMachineDAO.save(ticketMachine);
                    message = "ticket machine uuid updated FROM: " + ticketMachineUuid + "    TO: " + updateUUID;

                }
            }
        }
    } else if ("updateStation".equals(actionStr)) {
        if (ticketMachineUuid == null || ticketMachineUuid.isEmpty()) {
            errorMessage = "cannot update station name with empty ticketMachineUuid";
        } else {
            ticketMachine = ticketMachineDAO.findByUuid(ticketMachineUuid);
            if (ticketMachine == null) {
                errorMessage = "Cannot update station. Ticket machine uuid does not exist:  " + ticketMachineUuid;
            } else {
                station.setName(updateStation);
                station = stationDAO.findByName(updateStation);
                if (station == null) {
                    errorMessage = "Cannot update ticket machine station. Station does not exist:  " + updateStation;
                } else {
                    try {
                        ticketMachine.setStation(station);
                        ticketMachine = ticketMachineDAO.save(ticketMachine);
                        message = "Ticket machine " + ticketMachineUuid + " moved to station " + updateStation;

                    } catch (NullPointerException | NumberFormatException ex) {
                        errorMessage = "Cannot update station. Cannot parse zone:  " + updateStation;
                    }
                }
            }
        }
    }

%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Ticket Machine Manager</title>
    </head>
    <body>

        <H1>Ticket Machine Manager</H1>

        <form action="./index.html" method="get">
            <button type="submit" style="width:200px">Station Controller Home</button>
        </form> 
        <form action="./stationList.jsp" method="get">
            <button type="submit" style="width:200px">Return to Station List</button>
        </form> 
        <BR>

        <!-- print error message if there is one -->
        <div style="color:red;"><%=errorMessage%></div>
        <div style="color:green;"><%=message%></div>

        <!-- if you used method post the url parameters would be hidden -->
        <form action="./ticketMachineManager.jsp" method="get">
        </p>UUID: <input type="text" size="36" name="updateUUID" value="<%=ticketMachine.getUuid()%>">
        <input type="hidden" name="ticketMachineUuid" value="<%=ticketMachine.getUuid()%>">
        <input type="hidden" name="stationName" value="<%=ticketMachine.getStation().getName()%>">
        <input type="hidden" name="action" value="updateUUID">
        <button type="submit" >Update Ticket Machine UUID</button>
    </p>
</form>
<form action="./ticketMachineManager.jsp" method="get">
    <p>Station: <input type="text" name="updateStation" value="<%=ticketMachine.getStation().getName()%>">
        <input type="hidden" name="ticketMachineUuid" value="<%=ticketMachine.getUuid()%>">
        <input type="hidden" name="action" value="updateStation">
        <button type="submit" >Update Ticket Machine Station</button>
    </p>
</form> 
</body>
</html>
