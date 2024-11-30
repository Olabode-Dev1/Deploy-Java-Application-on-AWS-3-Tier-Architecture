#!/bin/bash
sudo yum install -y java-11-openjdk amazon-cloudwatch-agent amazon-ssm-agent
wget https://downloads.apache.org/tomcat/tomcat-9/v9.0.70/bin/apache-tomcat-9.0.70.tar.gz
tar -xvf apache-tomcat-9.0.70.tar.gz -C /opt
sudo mv /opt/apache-tomcat-9.0.70 /opt/tomcat
sudo systemctl enable tomcat
