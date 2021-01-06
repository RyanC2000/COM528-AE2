/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package org.solent.com528.project.impl.dao.jpa;

import java.io.File;
import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;
import org.solent.com528.project.impl.dao.jaxb.PriceCalculatorDAOJaxbImpl;
import static org.solent.com528.project.impl.dao.jpa.StationDAOJpaImpl.LOG;
import org.solent.com528.project.model.dao.DAOFactory;
import org.solent.com528.project.model.dao.PriceCalculatorDAO;
import org.solent.com528.project.model.dao.StationDAO;
import org.solent.com528.project.model.dao.TicketMachineDAO;

/**
 *
 * @author cgallen
 */
public class DAOFactoryJPAImpl implements DAOFactory {

    // note protected so that the child classes can access these fields
    // THIS HAS TO MATCH THE persistance.xml
    protected static final String PERSISTENCE_UNIT_NAME = "modelPersistence";
    protected static EntityManagerFactory factory;
    protected static EntityManager em;
    protected static TicketMachineDAO ticketMachineDAO;
    protected static StationDAO stationDAO;
    protected final static String TMP_DIR = System.getProperty("java.io.tmpdir");

    protected static PriceCalculatorDAO priceCalculatorDAO;
    protected static final String pricingDetailsFile = TMP_DIR + File.separator + "client" + File.separator + "pricingDetailsFile.xml";

    static {
        factory = Persistence.createEntityManagerFactory(PERSISTENCE_UNIT_NAME);
        em = factory.createEntityManager();

        // note it is important that all DAO's share same entity manager
        ticketMachineDAO = new TicketMachineDAOJpaImpl(em);
        stationDAO = new StationDAOJpaImpl(em);
        priceCalculatorDAO = new PriceCalculatorDAOJaxbImpl(pricingDetailsFile);
    }

    @Override
    public void shutDown() {
        if (em != null) synchronized (this) {
            if (em != null) {
                em.close();
            }
        }
    }

    @Override
    public TicketMachineDAO getTicketMachineDAO() {
        return ticketMachineDAO;
    }

    @Override
    public StationDAO getStationDAO() {
        return stationDAO;
    }

    @Override
    public PriceCalculatorDAO getPriceCalculatorDAO() {
        if (priceCalculatorDAO == null) {
            LOG.debug("creating new priceCalculatorDAO ");
            synchronized (this) {
                if (priceCalculatorDAO == null) {
                    priceCalculatorDAO = new PriceCalculatorDAOJaxbImpl(pricingDetailsFile);
                }
            }
        }
        return priceCalculatorDAO;

    }
}