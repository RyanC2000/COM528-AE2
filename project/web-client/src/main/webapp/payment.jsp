<%-- 
    Document   : payment
    Created on : 28 Dec 2020, 17:39:47
    Author     : ryanj
--%>

<%@page import="org.solent.com528.project.model.dto.Ticket"%>
<%@page import="org.solent.com528.project.model.dto.Rate"%>
<%@page import="org.solent.com528.project.model.util.DateTimeAdapter"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.text.DateFormat"%>
<%@page import="java.text.DateFormat"%>
<%@page import="java.util.Date"%>
<%@page import="org.solent.com528.project.clientservice.impl.TicketEncoderImpl"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%

    DateFormat df = new SimpleDateFormat(DateTimeAdapter.DATE_FORMAT);

    //RETIEVE TICKET PARAMETERS
    String startStation = request.getParameter("startStationStr");
    Date departureTime = df.parse(request.getParameter("departureTimeStr"));
    Integer zones = Integer.parseInt(request.getParameter("zonesStr"));
    Rate rate = Rate.valueOf(request.getParameter("rateStr"));
    Double cost = Double.parseDouble(request.getParameter("costStr"));

    //SET ENCRYPTED HASH AND RETURN TICKET
    Ticket ticket = new Ticket();
    ticket.setStartStation(startStation);
    ticket.setIssueDate(departureTime);
    ticket.setCost(cost);
    ticket.setRate(rate);
    ticket.setZones(zones);

    String encodedTicketStr = TicketEncoderImpl.encodeTicket(ticket);

%>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Transaction Completed</title>
    </head>
    <BR>
    <body>
        <h1>Payment Successful!</h1>
        <h2>Collect Your Ticket:</h2>
        <textarea id="ticketTextArea" rows="10" cols="120"><%=encodedTicketStr%></textarea>
        <BR>
        <BR>
        <form action="./index.html" method="get">
            <button type="submit" style="width:200px">Ticket Machine Home</button>
        </form> 
    </body>
</html>