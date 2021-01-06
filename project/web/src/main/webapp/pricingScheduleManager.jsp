<%-- 
    Document   : pricingScheuleManager
    Created on : 4 Jan 2021, 19:25:25
    Author     : ryanj
--%>

<%@page import="java.io.File"%>
<%@page import="org.solent.com528.project.impl.dao.jaxb.PriceCalculatorDAOJaxbImpl"%>
<%@page import="org.solent.com528.project.model.dto.Rate"%>
<%@page import="java.util.ArrayList"%>
<%@page import="org.solent.com528.project.model.dto.PriceBand"%>
<%@page import="java.util.List"%>
<%@page import="org.solent.com528.project.model.dto.PricingDetails"%>
<%@page import="org.solent.com528.project.model.dao.PriceCalculatorDAO"%>
<%@page import="org.solent.com528.project.impl.web.WebObjectFactory"%>
<%@page import="org.solent.com528.project.model.service.ServiceFacade"%>

<%
    //ACCESSING SERVICES
    ServiceFacade serviceFacade = (ServiceFacade) WebObjectFactory.getServiceFacade();
    PriceCalculatorDAO priceCalculatorDAO = serviceFacade.getPriceCalculatorDAO();

    //SET UP ERROR MESSAGES
    String errorMessage = "";
    String message = "";

    //ACCESSING REQUEST PARAMETERS
    String actionStr = request.getParameter("action");
    String peakPricePerZoneStr = request.getParameter("peakPricePerZoneStr");
    String OffpeakPricePerZoneStr = request.getParameter("OffpeakPricePerZoneStr");

    String newPriceBandHourStr = request.getParameter("newPriceBandHourStr");
    String newPriceBandMinuteStr = request.getParameter("newPriceBandMinuteStr");
    String newPriceBandRateStr = request.getParameter("newPriceBandRateStr");

    String deletePriceBandHourStr = request.getParameter("deletePriceBandHourStr");
    String deletePriceBandMinuteStr = request.getParameter("deletePriceBandMinuteStr");
    String deletePriceBandRateStr = request.getParameter("deletePriceBandRateStr");

    PricingDetails pricingDetails = priceCalculatorDAO.getPricingDetails();
    pricingDetails.getPriceBandList();
    pricingDetails.getPeakPricePerZone();
    pricingDetails.getOffpeakPricePerZone();
    List<PriceBand> priceBandList = pricingDetails.getPriceBandList();

    //CHECK OPERATIONS
    if (actionStr == null || actionStr.isEmpty()) {

    } else if ("updatePeakPricePerZone".equals(actionStr)) {
        try {
            Double peakPricePerZone = Double.parseDouble(peakPricePerZoneStr);
            pricingDetails.setPeakPricePerZone(peakPricePerZone);
            priceCalculatorDAO.savePricingDetails(pricingDetails);
            message = "Peak price per zone set: " + peakPricePerZone;

        } catch (NullPointerException | NumberFormatException ex) {
            errorMessage = "Cannot update peak price per zone. Cannot parse peak price per zone  " + peakPricePerZoneStr;
        }

    } else if ("updateOffpeakPricePerZone".equals(actionStr)) {
        try {
            Double OffpeakPricePerZone = Double.parseDouble(OffpeakPricePerZoneStr);
            pricingDetails.setOffpeakPricePerZone(OffpeakPricePerZone);
            priceCalculatorDAO.savePricingDetails(pricingDetails);
            message = "Offpeak price per zone set: " + OffpeakPricePerZoneStr;

        } catch (NullPointerException | NumberFormatException ex) {
            errorMessage = "Cannot update peak price per zone. Cannot parse offpeak price per zone  " + OffpeakPricePerZoneStr;
        }

    } else if ("deletePriceBand".equals(actionStr)) {
        try {
            Integer removeHour = Integer.parseInt(deletePriceBandHourStr);
            Integer removeMinute = Integer.parseInt(deletePriceBandMinuteStr);
            Rate removeRate = Rate.valueOf(deletePriceBandRateStr);

            PriceBand priceBandRemove = new PriceBand();
            priceBandRemove.setRate(removeRate);
            priceBandRemove.setHour(removeHour);
            priceBandRemove.setMinutes(removeMinute);
            System.out.println("removing priceband:" + priceBandRemove);
            priceCalculatorDAO.deletePriceBand(priceBandRemove);
            pricingDetails.getPriceBandList();
            priceCalculatorDAO.getPricingDetails();

            response.sendRedirect("./pricingScheduleManager.jsp");
            
            message = "Price band deleted";

        } catch (NullPointerException | NumberFormatException ex) {
            errorMessage = "Cannot delete price band";
        }

    } else if ("updatePriceBand".equals(actionStr)) {

    } else if ("deleteAllPriceBands".equals(actionStr)) {
        List<PriceBand> emptyPriceBandList = new ArrayList();
        pricingDetails.setPriceBandList(emptyPriceBandList);
        priceCalculatorDAO.savePricingDetails(pricingDetails);
        priceCalculatorDAO.getPricingDetails();

        response.sendRedirect("./pricingScheduleManager.jsp");

        message = "All price bands deleted";

    } else if ("createNewPriceBand".equals(actionStr)) {
        try {
            Integer newPriceBandHour = Integer.parseInt(newPriceBandHourStr);
            Integer newPriceBandMinute = Integer.parseInt(newPriceBandMinuteStr);
            Rate newPriceBandRate = Rate.valueOf(newPriceBandRateStr);

            PriceBand newPriceBand = new PriceBand();

            newPriceBand.setHour(newPriceBandHour);
            newPriceBand.setMinutes(newPriceBandMinute);
            newPriceBand.setRate(newPriceBandRate);

            priceBandList.add(newPriceBand);
            priceCalculatorDAO.savePricingDetails(pricingDetails);

            message = "New price band created";

        } catch (NullPointerException | NumberFormatException ex) {
            errorMessage = "Cannot add price band. Cannot parse some variable somewhere in here";
        }
    }

%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Pricing Schedule Manager</title>
    </head>
    <body>

        <h1>Pricing Schedule Manager</h1>
        <form action="./index.html" method="get">
            <button type="submit" style="width:200px">Station Controller Home</button>
        </form> 

        <BR>
        <div style="color:red;"><%=errorMessage%></div>
        <div style="color:green;"><%=message%></div>
        <BR>

        <h2>Current Rates</h2>
        <form action="./pricingScheduleManager.jsp" method="get">
            <p>Peak Price Per Zone: <input type="text" size="36" name="peakPricePerZoneStr" value="<%=pricingDetails.getPeakPricePerZone()%>">
                <input type="hidden" name="peakPricePerZoneStr" value="<%=pricingDetails.getPeakPricePerZone()%>">
                <input type="hidden" name="action" value="updatePeakPricePerZone">
                <button type="submit" >Update</button>
            </p>
        </form>
        <form action="./pricingScheduleManager.jsp" method="get">
            <p>Off-Peak Price Per Zone: <input type="text" size="36" name="OffpeakPricePerZoneStr" value="<%=pricingDetails.getOffpeakPricePerZone()%>">
                <input type="hidden" name="OffpeakPricePerZoneStr" value="<%=pricingDetails.getOffpeakPricePerZone()%>">
                <input type="hidden" name="action" value="updateOffpeakPricePerZone">
                <button type="submit" >Update</button>
            </p>
        </form>

        <h2>Current Pricing Schedule</h2>
        <table border="1">

            <tr>
                <th>Start Hour</th>
                <th>Start Minute</th>
                <th>Rate</th>
            </tr>
            <%
                for (PriceBand priceBand : priceBandList) {
            %>
            <tr>
                <td><%= priceBand.getHour()%></td>
                <td><%= priceBand.getMinutes()%></td>
                <td><%= priceBand.getRate()%></td>
                <td>
                    <form action="./pricingScheduleManager.jsp" method="get">
                        <input type="hidden" size="36" name="deletePriceBandHourStr" value="<%= priceBand.getHour()%>" readonly>
                        <input type="hidden" size="36" name="deletePriceBandMinuteStr" value="<%= priceBand.getMinutes()%>" readonly>
                        <input type="hidden" size="36" name="deletePriceBandRateStr" value="<%= priceBand.getRate()%>" readonly>
                        <input type="hidden" name="action" value="deletePriceBand">
                        <button type="submit" >Delete</button>
                    </form>
                </td>
            </tr>
            <%
                }
            %>
        </table> 

        <BR>
        <form action="./pricingScheduleManager.jsp" method="post">
            <input type="hidden" name="action" value="deleteAllPriceBands">
            <button type="submit" style="color:red;">Delete All Price Bands</button>
        </form> 
        <BR>

        <h2>Create New Price Band</h2>
        <form action="./pricingScheduleManager.jsp"  method="post" >
            <table>
                <tr>
                    <td>Start Hour</td>
                    <td><input type="text" name="newPriceBandHourStr" value="" placeholder="HH"></td>
                </tr>
                <td>Start Minute</td>
                <td><input type="text" name="newPriceBandMinuteStr" value="" placeholder="mm"></td>
                </tr>
                <tr>
                    <td>Rate:</td>
                    <td><input type="text" name="newPriceBandRateStr" value="" placeholder="PEAK OFFPEAK"></td>
                </tr>
            </table>
            <BR>
            <input type="hidden" name="action" value="createNewPriceBand">
            <input type="hidden" name="newPriceBandHourStr" value="newPriceBandHourStr">
            <input type="hidden" name="newPriceBandMinuteStr" value="newPriceBandMinuteStr">
            <input type="hidden" name="newPriceBandRateStr" value="newPriceBandRateStr">
            <button type="submit" >Create New Price Band</button>
        </form> 

    </body>
</html>
