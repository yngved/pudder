package org.apache.activemq.jms_webapp;

import org.apache.log4j.Logger;

public class JmsQueueMessage {
	
	Logger log = Logger.getLogger(JmsQueueMessage.class); 
	
	public JmsQueueMessage() {		
		log.warn("warn->init");
		log.debug("debug->init");
		log.info("info->init");
		
	}
	
	public void handleMessage(String message) {
		System.out.println("JmsQueueMessage::handleMessage " + message);
		log.debug("JmsQueueMessage::handleMessage " + message);
	
	}
}
