package org.apache.activemq.jms_webapp;

import javax.jms.Message;
import javax.jms.MessageListener;

import org.apache.log4j.Logger;

public class JmsTopicMessage implements MessageListener {
	
	Logger log = Logger.getLogger(JmsTopicMessage.class);

	public JmsTopicMessage() {		
		log.warn("warn->init");
		log.debug("debug->init");
		log.info("info->init");
	}
	
	public void onMessage(Message message) {
		System.out.println("JmsTopicMessage::onMessage()");
		log.info("info->init -> onMessage");
		
	}

}
