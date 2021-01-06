/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package org.solent.com528.project.impl.rest;

/**
 *
 * @author gallenc
 */
import java.util.ArrayList;
import java.util.List;
import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.solent.com528.project.impl.web.WebObjectFactory;
import org.solent.com528.project.model.dao.PriceCalculatorDAO;
import org.solent.com528.project.model.dao.StationDAO;
import org.solent.com528.project.model.dao.TicketMachineDAO;
import org.solent.com528.project.model.dto.PriceBand;
import org.solent.com528.project.model.dto.PricingDetails;
import org.solent.com528.project.model.dto.Rate;

import org.solent.com528.project.model.dto.ReplyMessage;
import org.solent.com528.project.model.dto.Station;
import org.solent.com528.project.model.dto.TicketMachine;
import org.solent.com528.project.model.dto.TicketMachineConfig;
import org.solent.com528.project.model.service.ServiceFacade;

/**
 * To make the ReST interface easier to program. All of the replies are
 * contained in ReplyMessage classes but only the fields indicated are populated
 * with each reply. All replies will contain a code and a debug message.
 */
@Path("/stationService")
public class TicketMachineRestService {

    // SETS UP LOGGING 
    // note that log name will be org.solent.com528.factoryandfacade.impl.rest.TicketMachineRestService
    final static Logger LOG = LogManager.getLogger(TicketMachineRestService.class);

    /**
     * this is a very simple rest test message which only returns a string
     *
     * http://localhost:8080/projectfacadeweb/rest/stationService/
     *
     * @return String simple message
     */
    @GET
    public String message() {
        LOG.debug("stationService called");
        return "Hello, rest!";
    }

    /**
     * get heartbeat
     *
     * http://localhost:8080/projectfacadeweb/rest/stationService/getTicketMachineConfig?uuid=xyz
     *
     * @return list of all Animals in List<String> replyMessage.getStringList()
     */
    @GET
    @Path("/getTicketMachineConfig")
    @Produces({MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public Response getTicketMachineConfig(@QueryParam("uuid") String uuid) {
        try {

            ServiceFacade serviceFacade = WebObjectFactory.getServiceFacade();
            StationDAO stationDAO = serviceFacade.getStationDAO();
            PriceCalculatorDAO priceCalculatorDAO = serviceFacade.getPriceCalculatorDAO();
            TicketMachineDAO ticketMachineDAO = serviceFacade.getTicketMachineDAO();

            ReplyMessage replyMessage = new ReplyMessage();
            LOG.debug("/getTicketMachineConfig called  uuid=" + uuid);
            // NOTE change this to uuid.isEmpty() if using java 8
            if (uuid == null || uuid.isEmpty()) {
                throw new IllegalArgumentException("uuid query must be defined ?uuid=xxx");
            }

            TicketMachine ticketMachine = ticketMachineDAO.findByUuid(uuid);
            String stationName = ticketMachine.getStation().getName();
            Integer stationZone = ticketMachine.getStation().getZone();

            // STATION LIST
            List<Station> stationList = stationDAO.findAll();

            // 200 CODE
            replyMessage.setCode(Response.Status.OK.getStatusCode());

            replyMessage.setCode(Response.Status.OK.getStatusCode());
            replyMessage.setDebugMessage("this is a dummy implemetation for testing");
            TicketMachineConfig ticketMachineConfig = new TicketMachineConfig();

            PricingDetails pricingDetails = priceCalculatorDAO.getPricingDetails();
            ticketMachineConfig.setPricingDetails(pricingDetails);

            ticketMachineConfig.setStationList(stationList);

            ticketMachineConfig.setStationName(stationName);
            ticketMachineConfig.setUuid(uuid);

            ticketMachineConfig.setStationZone(stationZone);

            replyMessage.setTicketMachineConfig(ticketMachineConfig);

            return Response.status(Response.Status.OK).entity(replyMessage).build();

        } catch (Exception ex) {
            LOG.error("error calling /getHeartbeat ", ex);
            ReplyMessage replyMessage = new ReplyMessage();
            replyMessage.setCode(Response.Status.INTERNAL_SERVER_ERROR.getStatusCode());
            replyMessage.setDebugMessage("error calling /getTicketMachineConfig " + ex.getMessage());
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(replyMessage).build();
        }
    }

}