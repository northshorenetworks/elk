elk
===
Docker Image of ELK stack specific to pfSense

This is an adaptation of Elijah Paul's post Monitoring pfSense (2.1) logs using ELK (ElasticSearch, Logstash, Kibana) 
http://elijahpaul.co.uk/monitoring-pfsense-2-1-logs-using-elk-logstash-kibana-elasticsearch/

Dockerfile was modified from cyberabis' docker-elkauto:
https://registry.hub.docker.com/u/cyberabis/docker-elkauto/

Prerequisites:

Docker / www.docker.com

4 Steps to ELK stack for pfSense

1.  Edit conf/logstash.conf and change the pfSense IP to the IP address of your pfSense firewall.

2.  Build the Docker image (From within the northshore/elk directory where the Dockerfile lives)
	sudo docker build -t northshore/elk .
	
3.  Run the Docker Image (Modify names/port mappings to suit your needs)
	sudo docker run -v <path to northshore/elk>/conf:/conf --name northshore-elk -p 80:80 -p 5140:5140/udp -p 9200:9200 northshore/elk elk_start.sh
	
4.  Point pfSense logs to elk server
	Status > System Logs > Settings(tab):
		Enable Remote logging, and set the Server1 IP to be the ip of the docker host:5140 and make sure you are sending Firewall Events.
		
Browse to http://dockerserver

Report any issues to docker@northshoresoftware.com	
    

