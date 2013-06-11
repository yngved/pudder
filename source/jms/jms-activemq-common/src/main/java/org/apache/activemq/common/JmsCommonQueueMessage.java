package org.apache.activemq.common;


import org.apache.log4j.Logger;

public class JmsCommonQueueMessage {
Logger log = Logger.getLogger(JmsCommonQueueMessage.class); 
	
	public JmsCommonQueueMessage() {		
		log.debug("debug->init");
		log.info("info->init");
		log.warn("warn->init");
		
	}
	
	public void handleMessage(String message) {
		System.out.println("JmsCommonQueueMessage::handleMessage " + message);
		log.debug("JmsCommonQueueMessage::handleMessage " + message);
	
	}

}
