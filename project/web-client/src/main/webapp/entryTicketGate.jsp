<%-- 
    Document   : entryTicketGate
    Created on : 6 Jan 2021, 09:07:51
    Author     : ryanj
--%>

<%@page import="org.solent.com528.project.impl.webclient.WebClientObjectFactory"%>
<%@page import="org.solent.com528.project.model.dao.StationDAO"%>
<%@page import="org.solent.com528.project.model.dao.PriceCalculatorDAO"%>
<%@page import="org.solent.com528.project.model.service.ServiceFacade"%>
<%@page import="java.util.Calendar"%>
<%@page import="org.solent.com528.project.model.dto.Rate"%>
<%@page import="org.solent.com528.project.model.dto.Ticket"%>
<%@page import="java.io.StringReader"%>
<%@page import="javax.xml.bind.Unmarshaller"%>
<%@page import="javax.xml.bind.JAXBContext"%>
<%@page import="org.solent.com528.project.clientservice.impl.TicketEncoderImpl"%>
<%@page import="org.solent.com528.project.clientservice.impl.TicketEncoder"%>
<%@page import="java.util.Date"%>
<%@page import="org.solent.com528.project.model.util.DateTimeAdapter"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.text.DateFormat"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    //SET UP ERROR MESSAGE
    String errorMessage = "";

    //ACCESSING SERVICES
    ServiceFacade serviceFacade = (ServiceFacade) WebClientObjectFactory.getServiceFacade();
    PriceCalculatorDAO priceCalculator = serviceFacade.getPriceCalculatorDAO();

    DateFormat df = new SimpleDateFormat(DateTimeAdapter.DATE_FORMAT);
    
    //SET INITIAL VALUES
    String currentTimeStr = request.getParameter("currentTime");
    if (currentTimeStr == null || currentTimeStr.isEmpty()) {
        currentTimeStr = df.format(new Date());
    }

    String departureStationStr = request.getParameter("departureStationStr");
    if (departureStationStr == null || departureStationStr.isEmpty()) {
        departureStationStr = "";
    }

    String ticketStr = request.getParameter("ticketStr");
    if (ticketStr == null || ticketStr.isEmpty()) {
        ticketStr = "";
    }

    //SET TICKET VALIDITY TO FALSE BY DEFAULT (GATE TO CLOSED BY DEFAULT)
    boolean valid = false;

    //TICKET VERIFICATION
    try {
        //INITIAL ERROR CHECKING
        if (ticketStr == null || ticketStr.isEmpty()) {
            errorMessage = "Please enter a ticket";
        }
        if (departureStationStr == null || departureStationStr.isEmpty()) {
            errorMessage = "Please enter the departure station";
        }

        //UNMARSHAL TICKET XML TO OBJECT
        JAXBContext jaxbContext = JAXBContext.newInstance("org.solent.com528.project.model.dto");
        Unmarshaller jaxbUnMarshaller = jaxbContext.createUnmarshaller();
        StringReader sr = new StringReader(ticketStr);
        Ticket decodedTicket = (Ticket) jaxbUnMarshaller.unmarshal(sr);

        //GET TICKET ATTRIBUTES FROM UNMARSHALLED TICKET XML
        String startStation = decodedTicket.getStartStation();
        Rate rate = decodedTicket.getRate();
        Date issueDate = decodedTicket.getIssueDate();

        //GET REQUIRED VARIABLES FOR TICKET VERIFICATION
        Date currentTime = df.parse(currentTimeStr);

        Date ticketDeadline = new Date();
        Calendar cal = Calendar.getInstance();
        cal.setTime(issueDate);
        cal.add(Calendar.HOUR_OF_DAY, 24);
        ticketDeadline = cal.getTime();

        Rate currentRate = priceCalculator.getRate(currentTime);

        if (TicketEncoderImpl.validateTicket(ticketStr) == false) {
            errorMessage = "Ticket authenticity could not be verified";
            valid = false;
        } else if (currentTime.before(issueDate) || currentTime.after(ticketDeadline)) {
            errorMessage = "Ticket is not in-date";
            valid = false;
        } else if (rate != currentRate) {
            errorMessage = "Ticket is not suitable for this time. Current rate is " + currentRate + " ; Ticket is for " + rate;
        } else if (!departureStationStr.equals(startStation)) {
            errorMessage = "You are departing from the wrong station " + departureStationStr + ". Ticket departure station is " + startStation;
            valid = false;
        } else {
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
        <title>Ticket Gate</title>
    </head>
    <body>
        <h1>Entry Ticket Gate</h1>
        
        <form action="./index.html" method="get">
            <button type="submit" style="width:200px">Ticket Machine Home</button>
        </form> 
        <BR>
        <!-- print error message if there is one -->
        <div style="color:red;"><%=errorMessage%></div>
        <form action="./entryTicketGate.jsp"  method="post" >
            <table>
                <tr>
                    <td>This station is: </td>
                    <td>
                        <input type="text" name="departureStationStr" value="<%=departureStationStr%>" placeholder="Departure Station">
                    </td>
                </tr>
                <tr>
                    <td>The current time is: </td>
                    <td><input type="text" name="currentTime" value="<%=currentTimeStr%>"></td>
                </tr>
                <tr>
                    <td>Insert ticket data here: </td>
                    <td><textarea name="ticketStr" rows="10" cols="120"><%=ticketStr%></textarea></td>
                </tr>
            </table>

            <button type="submit" >Verify Ticket</button>
        </form> 
        <BR>
        <% if (valid) { %>
        <div style="color:green;font-size:x-large">GATE OPEN</div>
        <%  } else {  %>
        <div style="color:red;font-size:x-large">GATE LOCKED</div>
        <% }%>
    </body>
</html>

