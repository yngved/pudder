sc stop tomcat6
timeout 5
call mvn clean package
del C:\application-server\apache-tomcat-6.0.37\webapps\jms-webapp.war /y
rd C:\application-server\apache-tomcat-6.0.37\webapps\jms-webapp /S /Q
xcopy ..\jms-activemq-webapp\target\jms-webapp.war C:\application-server\apache-tomcat-6.0.37\webapps /y
sc start tomcat6
