#!/bin/bash
sudo yum install -y nginx amazon-cloudwatch-agent amazon-ssm-agent
sudo systemctl start nginx
sudo systemctl enable nginx
