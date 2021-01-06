package org.solent.com528.project.clientservice.impl;

import org.solent.com528.project.model.dto.Ticket;

public abstract class TicketEncoder {

    public static String encodeTicket(Ticket ticket){
        return null;
    }

    public static boolean validateTicket(String encodedTicket) {
        return true;
    }
}
