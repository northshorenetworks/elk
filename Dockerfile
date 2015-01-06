# Dockerfile for ELK stack on Ubuntu base

# Help:
# 80=nginx, 9200=elasticsearch, 5140=logstash udp input
# Default command: docker run -d -v /conf/logstash:/conf -p 80:80 -p 5140:5140/udp -p 9200:9200 northshore/elk /elk_start.sh
# Default command will start ELK within a docker
# To login to bash: docker run -t -v /conf/logstash:/conf -i northshore/elk /bin/bash


FROM ubuntu:latest
MAINTAINER Northshore Network Solutions LLC 
# Initial update
RUN apt-get update

# This is to install add-apt-repository utility. All commands have to be non interactive with -y option
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common

# Install Oracle Java 8, accept license command is required for non interactive mode
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886 && \
   DEBIAN_FRONTEND=noninteractive add-apt-repository -y ppa:webupd8team/java && \
   apt-get update && \
   echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections &&\
   DEBIAN_FRONTEND=noninteractive apt-get install -y oracle-java8-installer

# Elasticsearch installation
# Start Elasticsearch by /elasticsearch/bin/elasticsearch. This will run on port 9200.
RUN wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.3.1.tar.gz && \
   tar xf elasticsearch-1.3.1.tar.gz && \
   rm elasticsearch-1.3.1.tar.gz && \
   mv elasticsearch-1.3.1 elasticsearch 

# Logstash installation
# Create a logstash.conf and start logstash by /logstash/bin/logstash agent -f logstash.conf
RUN wget https://download.elasticsearch.org/logstash/logstash/logstash-1.4.2.tar.gz && \
   tar xf logstash-1.4.2.tar.gz && \
   rm logstash-1.4.2.tar.gz && \
   mv logstash-1.4.2 logstash

# Kibana installation
RUN wget https://download.elasticsearch.org/kibana/kibana/kibana-3.1.0.tar.gz && \
   tar xf kibana-3.1.0.tar.gz && \
   rm kibana-3.1.0.tar.gz && \
   mv kibana-3.1.0  kibana

# Install curl utility just for testing
RUN apt-get update && \
   apt-get install -y curl

# Install Nginx
# Start or stop with /etc/init.d/nginx start/stop. Runs on port 80.
# Sed command is to make the worker threads of nginx run as user root
RUN apt-get update && \
   DEBIAN_FRONTEND=noninteractive apt-get install -y nginx && \
   sed -i -e 's/www-data/root/g' /etc/nginx/nginx.conf

# Deploy kibana to Nginx
RUN mv /usr/share/nginx/html /usr/share/nginx/html_orig && \
   mkdir /usr/share/nginx/html && \
   cp -r /kibana/* /usr/share/nginx/html

# Create a start bash script
RUN touch elk_start.sh && \
   echo '#!/bin/bash' >> elk_start.sh && \
   echo '/elasticsearch/bin/elasticsearch &' >> elk_start.sh && \
   echo 'cp -r /conf/dashboards/* /usr/share/nginx/html/app/dashboards/ ' >> elk_start.sh && \
   echo '/etc/init.d/nginx start &' >> elk_start.sh && \
   echo 'exec /logstash/bin/logstash agent -f /conf/logstash.conf' >> elk_start.sh && \
   chmod 777 elk_start.sh

