<%@page import="org.solent.com528.project.model.dto.Station"%>
<%@page import="java.util.Set"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.io.File"%>
<%@page import="java.io.StringReader"%>
<%@page import="javax.xml.bind.Unmarshaller"%>
<%@page import="javax.xml.bind.JAXBContext"%>
<%@page import="org.solent.com528.project.clientservice.impl.TicketEncoder"%>
<%@page import="org.solent.com528.project.clientservice.impl.TicketEncoderImpl"%>
<%@page import="org.solent.com528.project.model.util.DateTimeAdapter"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.text.DateFormat"%>
<%@page import="java.text.DateFormat"%>
<%@page import="org.solent.com528.project.model.dao.PriceCalculatorDAO"%>
<%@page import="org.solent.com528.project.model.dao.StationDAO"%>
<%@page import="org.solent.com528.project.impl.webclient.WebClientObjectFactory"%>
<%@page import="org.solent.com528.project.model.service.ServiceFacade"%>
<%@page import="org.solent.com528.project.model.dto.Rate"%>
<%@page import="java.util.Date"%>
<%@page import="org.solent.com528.project.model.dto.Ticket"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    //SET UP ERROR MESSAGE
    String errorMessage = "";

    //ACCESSING SERVICES
    ServiceFacade serviceFacade = (ServiceFacade) WebClientObjectFactory.getServiceFacade();
    PriceCalculatorDAO priceCalculator = serviceFacade.getPriceCalculatorDAO();
    StationDAO stationDAO = serviceFacade.getStationDAO();

    DateFormat df = new SimpleDateFormat(DateTimeAdapter.DATE_FORMAT);

    //SET INITIAL VALUES
    String startStationStr = WebClientObjectFactory.getStationName();

    String destinationStationStr = request.getParameter("destinationStationStr");
    if (destinationStationStr == null || destinationStationStr.isEmpty()) {
        destinationStationStr = "";
    }

    String departureTimeStr = request.getParameter("departureTimeStr");
    if (departureTimeStr == null || departureTimeStr.isEmpty()) {
        departureTimeStr = df.format(new Date());
    }

    String costStr = request.getParameter("costStr");
    if (costStr == null || costStr.isEmpty()) {
        costStr = "";
    }

    String rateStr = request.getParameter("rateStr");
    if (rateStr == null || rateStr.isEmpty()) {
        rateStr = "";
    }

    String zonesStr = request.getParameter("zonesStr");
    if (zonesStr == null || zonesStr.isEmpty()) {
        zonesStr = "";
    }

    //SET TICKET VALIDITY TO FALSE BY DEFAULT
    boolean valid = false;

    //TICKET CREATION
    try {
        //INITIAL ERROR CHECKING
        if (destinationStationStr == null || destinationStationStr.isEmpty()) {
            errorMessage = "Please enter the destination station";
        } else if (request.getParameter("departureTimeStr").equals(null) || request.getParameter("departureTimeStr").isEmpty()) {
            errorMessage = "Please enter a departure time";
        } else {

            //GET REQUIRED VARIABLES FOR TICKET VERIFICATION
            Date departureTime = df.parse(departureTimeStr);

            Double pricePerZone = priceCalculator.getPricePerZone(departureTime);
            Rate rate = priceCalculator.getRate(departureTime);

            Integer startZone = stationDAO.findByName(startStationStr).getZone();
            Integer destinationZone = stationDAO.findByName(destinationStationStr).getZone();

            Integer zones = Math.abs(destinationZone - startZone);
            Double cost = (zones * pricePerZone);

            zonesStr = Integer.toString(zones);
            costStr = Double.toString(cost);
            rateStr = rate.name();

            valid = true;

        }
    } catch (Exception ex) {
        errorMessage = ex.getMessage();
    }

    if (errorMessage == null || errorMessage.isEmpty()) {
        errorMessage = "";
    }

%>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Ticket Machine</title>
    </head>
    <body>
        <h1>Ticket Machine</h1>

        <form action="./index.html" method="get">
            <button type="submit" style="width:200px">Ticket Machine Home</button>
        </form> 
        <BR>
        <!-- print error message if there is one -->
        <div style="color:red;"><%=errorMessage%></div>
        <BR>
        <form action="./ticketGenerator.jsp"  method="post" >
            <table>
                <tr>
                    <td>Starting Station:</td>
                    <td><input type="text" name="startStationStr" value="<%=startStationStr%>" readonly></td>
                </tr>
                <tr>
                    <td>Destination Station:</td>
                    <td><input type="text" name="destinationStationStr" value="<%=destinationStationStr%>"></td>
                </tr>
                <tr>
                    <td>Departure Time:</td>
                    <td><input type="text" name="departureTimeStr" value="<%=departureTimeStr%>" placeholder="dd-mm-yy hh:mm:ss"></td>
                </tr>
                <tr>
                    <td>Zones:</td>
                    <td><input type="text" name="zonesStr" value="<%=zonesStr%>" placeholder="--" readonly></td>
                </tr>
                <tr>
                    <td>Rate:</td>
                    <td><input type="text" name="rateStr" value="<%=rateStr%>" placeholder="--" readonly></td>
                </tr>
                <tr>
                    <td>Cost:</td>
                    <td><input type="text" name="costStr" value="<%=costStr%>" placeholder="--" readonly></td>
                </tr>
            </table>
            <button type="submit" >Confirm Ticket Details</button>
        </form> 
        <BR>
        <% if (valid) {%>
        <form action="./payment.jsp"  method="post" >
            <button type="submit" >Proceed to Payment</button>
            <input type="hidden" name="startStationStr" value="<%= startStationStr%>">
            <input type="hidden" name="departureTimeStr" value="<%= departureTimeStr%>">
            <input type="hidden" name="zonesStr" value="<%= zonesStr%>">
            <input type="hidden" name="rateStr" value="<%= rateStr%>">
            <input type="hidden" name="costStr" value="<%= costStr%>">
        </form>
        <%  } else {%>
        <button type="button" disabled>Proceed to Payment</button>
        <% }%>
    </body>
</html>