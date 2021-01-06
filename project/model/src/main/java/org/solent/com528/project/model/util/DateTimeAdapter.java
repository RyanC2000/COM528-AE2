
package org.solent.com528.project.model.util;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import javax.xml.bind.annotation.adapters.XmlAdapter;

public class DateTimeAdapter extends XmlAdapter<String, Date> {

    public static final String DATE_FORMAT = "dd-MM-yyyy HH:mm:ss";

    private final DateFormat dateFormat = new SimpleDateFormat(DATE_FORMAT);

    @Override
    public Date unmarshal(String xml) throws Exception {
        synchronized (dateFormat) {
            return dateFormat.parse(xml);
        }
    }

    @Override
    public String marshal(Date object) throws Exception {
        synchronized (dateFormat) {
            return dateFormat.format(object);
        }
    }

}
