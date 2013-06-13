package org.apache.activemq.common;

import javax.jms.Message;
import javax.jms.MessageListener;

import org.apache.log4j.Logger;


public class JmsCommonTopicMessage implements MessageListener {
	Logger log = Logger.getLogger(JmsCommonTopicMessage.class); 
	
	public JmsCommonTopicMessage() {		
		log.info("info->init");
		log.warn("warn->init");
		log.debug("debug->init");
		
	}

	public void onMessage(Message message) {
		System.out.println("JmsCommonTopicMessage::onMessage()");	
	}
}
